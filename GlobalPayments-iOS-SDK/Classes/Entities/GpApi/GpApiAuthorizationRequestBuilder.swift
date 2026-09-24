import Foundation

struct GpApiAuthorizationRequestBuilder: GpApiRequestData {

    func generateRequest(for builder: AuthorizationBuilder, config: GpApiConfig?) -> GpApiRequest? {
        let merchantUrl: String = !(config?.merchantId?.isEmpty ?? true) ? "/merchants/\(config?.merchantId ?? "")" : .empty
        switch builder.transactionType {
        case .decrypt:
            let payload = createForDecrypt(builder, config)
            return GpApiRequest(
                endpoint: merchantUrl + GpApiRequest.Endpoints.decrypt(),
                method: .post,
                requestBody: payload.toString()
            )
        case .sale, .refund, .auth:
            let payload = createFromAuthorizationBuilder(builder, config)
            return GpApiRequest(
                endpoint: merchantUrl + GpApiRequest.Endpoints.transactions(),
                method: .post,
                requestBody: payload.toString()
            )
        case .dccRateLookup:
            let paymentMethod = createForVerify(builder, config)
            paymentMethod.set(for: "entry_mode", value: entryMode(for: builder, channel: config?.channel))
            if let builderTokenized = builder.paymentMethod as? Tokenizable {
                paymentMethod.set(for: "id", value: builderTokenized.token)
            }

            let payload = JsonDoc()
            
            payload.set(for: "account_name", value: config?.accessTokenInfo?.transactionProcessingAccountName)
            payload.set(for: "account_id", value: config?.accessTokenInfo?.transactionProcessingAccountID)
            payload.set(for: "channel", value: config?.channel.mapped(for: .gpApi))
            payload.set(for: "reference", value: builder.clientTransactionId ?? UUID().uuidString)
            .set(for: "amount", value: builder.amount?.toNumericCurrencyString(currency: builder.currency))
            payload.set(for: "currency", value: builder.currency)
            payload.set(for: "country", value: config?.country)
            payload.set(for: "payment_method", doc: paymentMethod)

            return GpApiRequest(
                endpoint: merchantUrl + GpApiRequest.Endpoints.currencyConversions(),
                method: .post,
                requestBody: payload.toString()
            )
        case .verify:
            if builder.requestMultiUseToken == true && ((builder.paymentMethod as? Tokenizable)?.token == nil) {
                let payload = createForVerify(builder, config)
                return GpApiRequest(
                    endpoint: merchantUrl + GpApiRequest.Endpoints.paymentMethods(),
                    method: .post,
                    requestBody: payload.toString()
                )
            } else {
                let payload = generateVerificationRequest(builder, config)
                return GpApiRequest(
                    endpoint: merchantUrl + GpApiRequest.Endpoints.verify(),
                    method: .post,
                    requestBody: payload.toString()
                )
            }
        case .create:
            let payload = JsonDoc()
            if let payByLinkData = builder.payByLinkData {
                if payByLinkData.type == .hosted_payment_page {
                    payload.set(for: "usage_limit", value: payByLinkData.usageLimit)
                    payload.set(for: "usage_mode", value: payByLinkData.usageMode?.mapped(for: .gpApi))
                    payload.set(for: "description", value: builder.requestDescription)
                    payload.set(for: "type", value: payByLinkData.type?.mapped(for: .gpApi))
                    payload.set(for: "expiration_date", value: payByLinkData.expirationDate?.format("yyyy-MM-dd'T'HH:mm:ss'Z'"))
                    
                    payload.set(for: "reference", value: builder.clientTransactionId)
                    payload.set(for: "shippable", value: payByLinkData.isShippable ?? false ? "YES" : "NO")
                    payload.set(for: "account_name", value: config?.accessTokenInfo?.transactionProcessingAccountName)
                    payload.set(for: "account_id", value: config?.accessTokenInfo?.transactionProcessingAccountID)
                    payload.set(for: "name", value: payByLinkData.name)
                    payload.set(for: "submit_button_label", value: payByLinkData.submitButtonLabel)
                    
                    payload.set(for: "payer", doc: setPayerInformation(builder))
                    
                    let order = JsonDoc()
                        .set(for: "amount", value: builder.amount?.toNumericCurrencyString(currency: builder.currency))
                        .set(for: "currency", value: builder.currency)
                        .set(for: "reference", value: builder.clientTransactionId ?? UUID().uuidString)
                        .set(for: "shipping_amount", value: payByLinkData.shippingAmount?.toNumericCurrencyString(currency: builder.currency))

                    if let surcharges = payByLinkData.surcharge, !surcharges.isEmpty {
                        let surchargeArray = surcharges.map { s -> JsonDoc in
                            let entry = JsonDoc()
                            entry.set(for: "card_type", value: s.cardType)
                            entry.set(for: "amount", value: s.amount)
                            return entry
                        }
                        order.set(for: "surcharge", values: surchargeArray)
                    }
                    
                    let transactionConfiguration = JsonDoc()
                        .set(for: "channel", value: config?.channel.mapped(for: .gpApi))
                        .set(for: "country", value: config?.country)
                        .set(for: "capture_mode", value: captureMode(for: builder))
                        .set(for: "currency_conversion_mode", value: payByLinkData.isDccEnabled == true ? "YES" : "NO")
                        .set(for: "allowed_payment_methods", value: mapAllowedPaymentMethod(payByLinkData.allowedPaymentMethods))
                    
                    let paymentMethodConfiguration = JsonDoc()
                    paymentMethodConfiguration.set(for: "entry_mode", value: payByLinkData.configuration?.entryMode?.mapped(for: .gpApi))
                    paymentMethodConfiguration.set(for: "storage_mode", value: payByLinkData.configuration?.storageMode?.mapped(for: .gpApi))

                    let authentications = JsonDoc()
                        .set(for: "preference", value:  payByLinkData.configuration?.challengeRequestIndicator?.mapped(for: .gpApi))
                        .set(for: "exempt_status", value: payByLinkData.configuration?.exemptStatus?.mapped(for: .gpApi))
                        .set(for: "billing_address_required", value: payByLinkData.configuration?.isBillingAddressRequired == true ? "YES" : "NO")
                    paymentMethodConfiguration.set(for: "authentications", doc: authentications)
                    
                    let apm = JsonDoc()
                        .set(for: "shipping_address_enabled", value: payByLinkData.configuration?.isShippingAddressEnabled == true ? "YES" : "NO")
                        .set(for: "address_override", value: payByLinkData.configuration?.isAddressOverrideAllowed == true ? "YES" : "NO")

                    // Cashpresso (and future APMs): serialize apm.configurations array
                    if let apmConfigurations = payByLinkData.configuration?.apmConfigurations, !apmConfigurations.isEmpty {
                        let configDocs = apmConfigurations.map { apmConfiguration -> JsonDoc in
                            let configDocument = JsonDoc()
                            configDocument.set(for: "provider", value: apmConfiguration.provider?.rawValue)
                            if let plans = apmConfiguration.paymentPlans, !plans.isEmpty {
                                configDocument.set(for: "payment_plans", value: plans.map { $0.rawValue })
                            }
                            return configDocument
                        }
                        apm.set(for: "configurations", values: configDocs)
                    }
                    paymentMethodConfiguration.set(for: "apm", doc: apm)

                    if let providers = payByLinkData.configuration?.digitalWalletProviders, !providers.isEmpty {
                        let digitalWallets = JsonDoc()
                        digitalWallets.set(for: "provider", value: providers.map { $0.rawValue })
                        paymentMethodConfiguration.set(for: "digital_wallets", doc: digitalWallets)
                    }

                    let shippingAddress = getBasicAddressInformation(builder.shippingAddress)
                    order.set(for: "shipping_address", doc: shippingAddress)
                    
                    let shippingPhone = JsonDoc()
                    shippingPhone.set(for: "country_code", value: builder.shippingPhone?.countryCode)
                    shippingPhone.set(for: "subscriber_number", value: builder.shippingPhone?.number)
                    order.set(for: "shipping_phone", doc: shippingPhone)

                    // Cashpresso order fields
                    order.set(for: "shipping_date", value: payByLinkData.shippingDate)
                    order.set(for: "shipping_method", value: payByLinkData.shippingMethod?.mapped(for: .gpApi))
                    if let taxAmount = payByLinkData.taxAmount {
                        order.set(for: "tax_amount", value: taxAmount.toNumericCurrencyString(currency: builder.currency))
                    }
                    if let orderItems = payByLinkData.orderItems, !orderItems.isEmpty {
                        order.set(for: "items", values: setItemDetailsListForHPP(orderItems, currency: builder.currency))
                    }
                    
                    order.set(for: "transaction_configuration", doc: transactionConfiguration)
                        .set(for: "payment_method_configuration", doc: paymentMethodConfiguration)
                    payload.set(for: "order", doc: order)
                    
                    let notification = JsonDoc()
                    notification.set(for: "cancel_url", value: payByLinkData.cancelUrl)
                    notification.set(for: "return_url", value: payByLinkData.returnUrl)
                    notification.set(for: "status_url", value: payByLinkData.statusUpdateUrl)

                    payload.set(for: "notifications", doc: notification)

                    if let displayConfig = payByLinkData.displayConfiguration {
                        let displayConfigDoc = JsonDoc()
                        displayConfigDoc.set(for: "iframe_dimensions_domain", value: displayConfig.iframeDimensionsDomain)
                        displayConfigDoc.set(for: "iframe_response_domain", value: displayConfig.iframeResponseDomain)
                        displayConfigDoc.set(for: "cardholder_name", value: displayConfig.cardholderName)
                        displayConfigDoc.set(for: "cvv", value: displayConfig.cvv)
                        payload.set(for: "display_configuration", doc: displayConfigDoc)
                    }

                    // Visa installments configuration for HPP
                    if let installments = builder.installmentData {
                        let installmentsData = JsonDoc()
                        if let fundingMode = installments.fundingMode, !fundingMode.isEmpty {
                            installmentsData.set(for: "funding_mode", value: fundingMode)
                        }
                        if let terms = installments.terms {
                            let termsDoc = JsonDoc()
                            termsDoc.set(for: "max_time_unit_number", value: terms.maxTimeUnitNumber)
                            termsDoc.set(for: "max_amount", value: terms.maxAmount)
                            installmentsData.set(for: "terms", doc: termsDoc)
                        }
                        payload.set(for: "installment", doc: installmentsData)
                    }

                    payload.set(for: "status", value: builder.customerData?.status)
                } else {
                    payload.set(for: "usage_limit", value: payByLinkData.usageLimit)
                    payload.set(for: "usage_mode", value: payByLinkData.usageMode?.mapped(for: .gpApi))
                    payload.set(for: "images", value: payByLinkData.images)
                    payload.set(for: "description", value: builder.requestDescription)
                    payload.set(for: "type", value: payByLinkData.type?.mapped(for: .gpApi))
                    payload.set(for: "expiration_date", value: payByLinkData.expirationDate?.format("yyyy-MM-dd"))
                    
                    let transaction = JsonDoc()
                    transaction.set(for: "country", value: config?.country)
                    transaction.set(for: "amount", value: builder.amount?.toNumericCurrencyString(currency: builder.currency))
                    transaction.set(for: "channel", value: config?.channel.mapped(for: .gpApi))
                    transaction.set(for: "currency", value: builder.currency)
                    transaction.set(for: "allowed_payment_methods", value: mapAllowedPaymentMethod(payByLinkData.allowedPaymentMethods))
                    
                    payload.set(for: "transactions", doc: transaction)
                    payload.set(for: "reference", value: builder.clientTransactionId)
                    payload.set(for: "shipping_amount", value: payByLinkData.shippingAmount?.toNumericCurrencyString(currency: builder.currency))
                    payload.set(for: "shippable", value: payByLinkData.isShippable ?? false ? "YES" : "NO")
                    payload.set(for: "account_name", value: config?.accessTokenInfo?.transactionProcessingAccountName)
                    payload.set(for: "name", value: payByLinkData.name)
                    
                    let notification = JsonDoc()
                    notification.set(for: "cancel_url", value: payByLinkData.cancelUrl)
                    notification.set(for: "return_url", value: payByLinkData.returnUrl)
                    notification.set(for: "status_url", value: payByLinkData.statusUpdateUrl)

                    payload.set(for: "notifications", doc: notification)
                    payload.set(for: "status", value: payByLinkData.status?.mapped(for: .gpApi))
                }
            }
            
            return GpApiRequest(
                endpoint: merchantUrl + "/links",
                method: .post,
                requestBody: payload.toString()
            )
        case .transferFunds:
            if let fundsData = builder.paymentMethod as? AccountFunds {
                let payload = JsonDoc()
                payload.set(for: "account_id", value: fundsData.accountId)
                payload.set(for: "account_name", value: fundsData.accountName)
                payload.set(for: "recipient_account_id", value: fundsData.recipientAccountId)
                payload.set(for: "reference", value: builder.clientTransactionId)
                payload.set(for: "amount", value: builder.amount?.toNumericCurrencyString(currency: builder.currency))
                payload.set(for: "description", value: builder.requestDescription)
                payload.set(for: "usable_balance_mode", value: fundsData.usableBalanceMode?.rawValue)
                
                let url = !(fundsData.merchantId?.isEmpty ?? true) ? "/merchants/\(fundsData.merchantId ?? "")" : .empty
                
                return GpApiRequest(
                    endpoint: url + GpApiRequest.Endpoints.transfers(),
                    method: .post,
                    requestBody: payload.toString()
                )
            } else {
                return nil
            }
        default:
            return nil
        }
    }

    private func createFromAuthorizationBuilder(_ builder: AuthorizationBuilder, _ config: GpApiConfig?) -> JsonDoc {
        let payload = JsonDoc()
            .set(for: "account_name", value: config?.accessTokenInfo?.transactionProcessingAccountName)
            .set(for: "account_id", value: config?.accessTokenInfo?.transactionProcessingAccountID)
            .set(for: "channel", value: config?.channel.mapped(for: .gpApi))
            .set(for: "country", value: config?.country)
            .set(for: "type", value: builder.transactionType == .refund ? "REFUND" : "SALE")
            .set(for: "capture_mode", value: captureMode(for: builder))
            .set(for: "authorization_mode", value: builder.allowPartialAuth ? "PARTIAL" : nil)
            .set(for: "amount", value: builder.amount?.toNumericCurrencyString(currency: builder.currency))
            .set(for: "currency", value: builder.currency)
            .set(for: "reference", value: builder.clientTransactionId ?? UUID().uuidString)
            .set(for: "description", value: builder.requestDescription)
            .set(for: "gratuity_amount", value: builder.gratuity?.toNumericCurrencyString(currency: builder.currency))
            .set(for: "surcharge_amount", value: builder.surchargeAmount?.toNumericCurrencyString(currency: builder.currency))
            .set(for: "convenience_amount", value: builder.convenienceAmount?.toNumericCurrencyString(currency: builder.currency))
            .set(for: "cashback_amount", value: builder.cashBackAmount?.toNumericCurrencyString(currency: builder.currency))
            .set(for: "ip_address", value: builder.customerIpAddress)
            .set(for: "payment_method", doc: createPaymentMethodParam(for: builder, channel: config?.channel))
            .set(for: "risk_assessment", values: builder.fraudFilterMode != nil ? mapFraudManagement(builder) : nil)
            .set(for: "link", doc: JsonDoc().set(for: "id", value: builder.paymentLinkId))

        if let dccId = builder.dccRateData?.dccId, !dccId.isEmpty {
            let currencyDoc = JsonDoc()
            currencyDoc.set(for: "id", value: dccId)
            payload.set(for: "currency_conversion", doc: currencyDoc)
        }

        if let commercialData = builder.commercialData {
            payload.set(for: "merchant_id", value: commercialData.merchantId)
            payload.set(for: "tax_amount", value: commercialData.taxAmounts?.toNumericCurrencyString(currency: builder.currency))
            payload.set(for: "tax_mode", value: commercialData.taxMode)
            payload.set(for: "purchase_order_number", value: commercialData.poNumber)
            
            // payment_method
            if let paymentMethod = commercialData.paymentMethod {
                let paymentMethodDoc = JsonDoc()
                paymentMethodDoc.set(for: "first_name", value: paymentMethod.firstName)
                paymentMethodDoc.set(for: "last_name", value: paymentMethod.lastName)
                paymentMethodDoc.set(for: "entry_mode", value: paymentMethod.entryMethod?.rawValue)
                if let card = paymentMethod.card {
                    let cardDoc = JsonDoc()
                    cardDoc.set(for: "category", value: card.category)
                    cardDoc.set(for: "track", value: card.track)
                    cardDoc.set(for: "track_number", value: card.trackNumber)
                    cardDoc.set(for: "avs_postal_code", value: card.avsPostalCode)
                    paymentMethodDoc.set(for: "card", doc: cardDoc)
                }
                payload.set(for: "payment_method", doc: paymentMethodDoc)
            }

            // order
            if let order = builder.orderDetails {
                let orderDoc = JsonDoc()
                if !order.taxes.isEmpty {
                    var taxesArray: [JsonDoc] = []
                    for tax in order.taxes {
                        let taxDoc = JsonDoc()
                        taxDoc.set(for: "type", value: tax.type)
                        taxDoc.set(for: "amount", value: tax.amount)
                        taxesArray.append(taxDoc)
                    }
                    orderDoc.set(for: "taxes", values: taxesArray)
                }
                orderDoc.set(for: "local_tax_percentage", value: order.localTaxPercentage)
                orderDoc.set(for: "buyer_recipient_name", value: order.buyerRecipientName)
                orderDoc.set(for: "state_tax_id_reference", value: order.stateTaxIdReference)
                orderDoc.set(for: "merchant_tax_id_reference", value: order.merchantTaxIdReference)
                payload.set(for: "order", doc: orderDoc)
            }

            // payer
            if let payer = builder.payerDetails {
                let payerDoc = JsonDoc()
                payerDoc.set(for: "tax_id_reference", value: payer.taxIdReference)
                payerDoc.set(for: "name", value: payer.name)
                payerDoc.set(for: "email", value: payer.email)
                payerDoc.set(for: "country", value: payer.country)
                payerDoc.set(for: "landline_phone", value: payer.landlinePhone)
                payerDoc.set(for: "mobile_phone", value: payer.mobilePhone)
                let billingAddress = payer.billingAddress
                let addressDoc = JsonDoc()
                addressDoc.set(for: "line_1", value: billingAddress?.streetAddress1)
                addressDoc.set(for: "line_2", value: billingAddress?.streetAddress2)
                addressDoc.set(for: "city", value: billingAddress?.city)
                addressDoc.set(for: "state", value: billingAddress?.state)
                addressDoc.set(for: "postal_code", value: billingAddress?.postalCode)
                addressDoc.set(for: "country", value: billingAddress?.country)
                payerDoc.set(for: "billing_address", doc: addressDoc)
                payload.set(for: "payer", doc: payerDoc)
            }
        }

        payload.set(for: "merchant_category", value: builder.merchantCategory?.rawValue);
        
        if let masked = builder.maskedDataResponse {
            payload.set(for: "masked", value: masked ? "YES" : "NO")
        }
        

        // set order reference
        if !builder.orderId.isNilOrEmpty {
            let order = JsonDoc()
                .set(for: "reference", value: builder.orderId)
            payload.set(for: "order", doc: order)
        }

        if let storedCredential = builder.storedCredential {
            payload.set(for: "initiator", value: builder.storedCredential?.initiator.mapped(for: .gpApi))
            let storedCredential = JsonDoc()
                .set(for: "model", value: storedCredential.type.mapped(for: .gpApi))
                .set(for: "reason", value: storedCredential.reason.mapped(for: .gpApi))
                .set(for: "sequence", value: storedCredential.sequence.mapped(for: .gpApi))
                .set(for: "contract_reference", value: storedCredential.contractReferenc)
            payload.set(for: "stored_credential", doc: storedCredential)
            
            //set installment data
            if builder.installmentData != nil && builder.storedCredential?.type == .installment {
                if let installmentData = builder.installmentData {
                    payload.set(for: "installment", doc: setInstallmentData(installmentData))
                }
            }
        }

        if builder.paymentMethod is eCheck || builder.paymentMethod is BNPL {
            payload.set(for: "payer", doc: setPayerInformation(builder))
        }
        
        if let apm = builder.paymentMethod as? AlternatePaymentMethod,
           apm.alternativePaymentMethodType == .ERATY {
            payload.set(for: "payer", doc: setERatyPayerInformation(builder))
        }

        if let apm = builder.paymentMethod as? AlternatePaymentMethod,
           apm.alternativePaymentMethodType == .CASHPRESSO {
            payload.set(for: "payer", doc: setCashpressoPayerInformation(builder))
        }

        if let apm = builder.paymentMethod as? AlternatePaymentMethod,
           apm.alternativePaymentMethodType == .BLIK, apm.blikMode == .levelZero {
            payload.set(for: "payer", doc: setBlikPayerInformation(builder))
        }

        if builder.paymentMethod is BNPL || builder.paymentMethod is Credit {
            setOrderInformation(builder, requestBody: payload)
        }

        if let apm = builder.paymentMethod as? AlternatePaymentMethod,
           apm.alternativePaymentMethodType == .CASHPRESSO {
            setCashpressoOrderInformation(builder, requestBody: payload)
        }
        
        if builder.paymentMethod is AlternatePaymentMethod || builder.paymentMethod is BNPL || builder.paymentMethod is BankPayment {
            payload.set(for:"notifications", doc: setNotificationUrls(builder.paymentMethod))
        }

        return payload
    }

    private func createForDecrypt(_ builder: AuthorizationBuilder, _ config: GpApiConfig?) -> JsonDoc {
        let payload = JsonDoc()
        payload.set(for: "account_name", value: config?.accessTokenInfo?.transactionProcessingAccountName)
        payload.set(for: "account_id", value: config?.accessTokenInfo?.transactionProcessingAccountID)
        payload.set(for: "type", value: "DECrypt")
        payload.set(for: "channel", value: config?.channel.mapped(for: .gpApi))
        payload.set(for: "country", value: config?.country)
        payload.set(for: "currency", value: builder.currency)
        payload.set(for: "reference", value: builder.clientTransactionId ?? UUID().uuidString)

        let paymentMethod = JsonDoc()
        if let creditCardData = builder.paymentMethod as? CreditCardData {
            paymentMethod.set(for: "name", value: creditCardData.cardHolderName)
            paymentMethod.set(for: "entry_mode", value: entryMode(for: builder, channel: config?.channel))

            let digitalWallet = JsonDoc()
            digitalWallet.set(for: "provider", value: creditCardData.mobileType)
            if let brand = creditCardData.cardType, brand != "Unknown", !brand.isEmpty {
                digitalWallet.set(for: "brand", value: brand.lowercased())
            }
            let tokenDoc = JsonDoc()
            tokenDoc.set(for: "data", value: creditCardData.token)
            tokenDoc.set(for: "dpa_reference", value: creditCardData.dpaReference)
            tokenDoc.set(for: "data_type_indicator", value: creditCardData.dataTypeIndicator)
            digitalWallet.set(for: "payment_token", doc: tokenDoc)
            paymentMethod.set(for: "digital_wallet", doc: digitalWallet)
        }
        payload.set(for: "payment_method", doc: paymentMethod)

        return payload
    }

    private func createForVerify(_ builder: AuthorizationBuilder, _ config: GpApiConfig?) -> JsonDoc {
        let payload = JsonDoc()
            .set(for: "account_name", value: config?.accessTokenInfo?.tokenizationAccountName)
            .set(for: "account_id", value: config?.accessTokenInfo?.tokenizationAccountID)
            .set(for: "name", value: builder.requestDescription)
            .set(for: "reference", value: builder.clientTransactionId ?? UUID().uuidString)
            .set(for: "usage_mode", value: builder.paymentMethodUsageMode?.mapped(for: .gpApi))
            .set(for: "fingerprint_mode", value: builder.customerData?.deviceFingerPrint)
        
        
        if let customerId = builder.customerId {
            let payer = JsonDoc()
            payer.set(for: "id", value: customerId)
            payload.set(for: "payer", doc: payer)
        }
        
        if let cardData = builder.paymentMethod as? CardData {
            let card = JsonDoc()
                .set(for: "number", value: cardData.number)
                .set(for: "expiry_month", value: cardData.expMonth > .zero ? "\(cardData.expMonth)".leftPadding(toLength: 2, withPad: "0") : .empty)
                .set(for: "expiry_year", value: cardData.expYear > .zero ? "\(cardData.expYear)".leftPadding(toLength: 4, withPad: "0").substring(with: 2..<4) : .empty)
                .set(for: "cvv", value: cardData.cvn)
            payload.set(for: "card", doc: card)
        }

        return payload
    }

    private func generateVerificationRequest(_ builder: AuthorizationBuilder, _ config: GpApiConfig?) -> JsonDoc {
        let payload = JsonDoc()
            .set(for: "account_name", value: config?.accessTokenInfo?.transactionProcessingAccountName)
            .set(for: "account_id", value: config?.accessTokenInfo?.transactionProcessingAccountID)
            .set(for: "channel", value: config?.channel.mapped(for: .gpApi))
            .set(for: "country", value: config?.country)
            .set(for: "reference", value: builder.clientTransactionId ?? UUID().uuidString)
            .set(for: "currency", value: builder.currency)
            .set(for: "payment_method", doc: createPaymentMethodParam(for: builder, channel: config?.channel))
            .set(for: "fingerprint_mode", value: builder.customerData?.deviceFingerPrint)

        return payload
    }

    private func entryMode(for builder: Builder, channel: Channel?) -> String {
        if channel == .cardPresent {
            if let track = builder.paymentMethod as? TrackData {
                if builder.tagData != nil {
                    if track.entryMethod == .proximity {
                        return PaymentEntryMode.contactlessChip.rawValue
                    }
                    if let emvData = EmvUtils.shared.parseTagData(builder.tagData) {
                        if emvData.isContactlessMsd() {
                            return PaymentEntryMode.contactlessSwipe.rawValue
                        }
                        return PaymentEntryMode.chip.rawValue
                    }
                }
                if track.entryMethod == .swipe {
                    return PaymentEntryMode.swipe.rawValue
                }
            }

            if let cardData = builder.paymentMethod as? CardData, cardData.cardPresent {
                return PaymentEntryMode.manual.rawValue
            }
            return PaymentEntryMode.swipe.rawValue
        } else if channel == .cardNotPresent {
            if let cardData = builder.paymentMethod as? CardData {
                if cardData.readerPresent {
                    return PaymentEntryMode.ecom.rawValue
                } else {
                    if let entryMethod = cardData.entryMethod {
                        switch entryMethod {
                        case ManualEntryMethod.PHONE:
                            return PaymentEntryMode.phone.rawValue
                        case ManualEntryMethod.MOTO:
                            return PaymentEntryMode.moto.rawValue
                        case ManualEntryMethod.MAIL:
                            return PaymentEntryMode.mail.rawValue
                        default:
                            break
                        }
                    }
                }

                if builder.transactionModifier == .encryptedMobile,
                   let creditCard = builder.paymentMethod as? CreditCardData,
                   creditCard.hasInAppPaymentData() {
                    return PaymentEntryMode.inApp.rawValue
                }
            }

            return PaymentEntryMode.ecom.rawValue
        }

        return ""
    }

    private func captureMode(for builder: Builder) -> String {
        if builder.multiCapture {
            return CaptureMode.multiple.rawValue
        } else if builder.transactionType == .auth {
            return CaptureMode.later.rawValue
        }
        return CaptureMode.auto.rawValue
    }

    private func createPaymentMethodParam(for builder: Builder, channel: Channel?) -> JsonDoc {
        let paymentMethod = JsonDoc()
        paymentMethod.set(for: "entry_mode", value: entryMode(for: builder, channel: channel))

        switch builder.paymentMethod {
        case let creditCardData as CreditCardData:
            creditCardDataPaymentMethod(paymentMethod, modifier: builder.transactionModifier, creditCardData: creditCardData, builder: builder)
        case let encryptable as Encryptable:
            encryptablePaymentMethod(paymentMethod, encryptable: encryptable)
        case let alternatePayment as AlternatePaymentMethod:
            alternatePaymentMethod(paymentMethod, alternatePayment: alternatePayment)
            return paymentMethod
        case let bnplPayment as BNPL:
            let dataName = "\(builder.customerData?.firstName ?? "") \(builder.customerData?.lastName ?? "")"
            paymentMethod.set(for: "name", value: dataName)
            paymentMethod.set(for: "bnpl", doc: bnplPaymentMethod(bnpl: bnplPayment))
            return paymentMethod
        case let openBankingPayment as BankPayment:
            openBankingPaymentMethod(openBankingPayment, builder: builder, paymentMethod: paymentMethod)
            return paymentMethod
        case .none, .some: break
        }
        
        var hasToken = false

        if let tokenizable = builder.paymentMethod as? Tokenizable, builder.transactionModifier != .encryptedMobile, builder.transactionModifier != .decryptedMobile {
            if let token = tokenizable.token, !token.isEmpty {
                paymentMethod.set(for: "id", value: token)
                hasToken = true
            }
        }

        if builder.requestMultiUseToken == true {
            paymentMethod.set(for: "storage_mode", value: "ON_SUCCESS")
        }

        if let check = builder.paymentMethod as? eCheck {
            paymentMethod.set(for: "name", value: check.checkHolderName)

            let bankTransfer = JsonDoc()
            bankTransfer.set(for: "account_number", value: check.accountNumber)
            bankTransfer.set(for: "account_type", value: check.accountType?.rawValue)
            bankTransfer.set(for: "check_reference", value: check.checkReference)
            bankTransfer.set(for: "sec_code", value: check.secCode)

            let bank = JsonDoc()
            bank.set(for: "code", value: check.routingNumber)
            bank.set(for: "name", value: check.bankName)

            let address = JsonDoc()
            address.set(for: "line_1", value: check.bankAddress?.streetAddress1)
            address.set(for: "line_2", value: check.bankAddress?.streetAddress2)
            address.set(for: "line_3", value: check.bankAddress?.streetAddress3)
            address.set(for: "city", value: check.bankAddress?.city)
            address.set(for: "postal_code", value: check.bankAddress?.postalCode)
            address.set(for: "state", value: check.bankAddress?.state)
            address.set(for: "country", value: check.bankAddress?.countryCode)

            bank.set(for: "address", doc: address)
            bankTransfer.set(for: "bank", doc: bank)
            paymentMethod.set(for: "bank_transfer", doc: bankTransfer)
            paymentMethod.set(for: "narrative", value: check.merchantNotes)
        } else {
            
            if let creditCard = builder.paymentMethod as? CreditCardData, let token = creditCard.token {
                hasToken = !token.isEmpty
            }
            
            if !hasToken {
                let cardDoc = CardUtils.generateCard(builder: builder)
                if let brandReference = builder.cardBrandTransactionId, !brandReference.isEmpty {
                    cardDoc.set(for: "brand_reference", value: brandReference)
                }
                paymentMethod.set(for: "card", doc: cardDoc)
            }
        }

        paymentMethod.set(for: "narrative", value: builder.dynamicDescriptor)

        return paymentMethod
    }

    private func creditCardDataPaymentMethod(_ paymentMethod: JsonDoc, modifier: TransactionModifier, creditCardData: CreditCardData, builder: Builder) {
        paymentMethod.set(for: "name", value: creditCardData.cardHolderName)

        if let secureEcom = creditCardData.threeDSecure {
            let authentication = JsonDoc()
            authentication.set(for: "id", value: secureEcom.serverTransactionId)
            let threeDs = JsonDoc()
            threeDs.set(for: "exempt_status", value: secureEcom.exemptStatus?.mapped(for: .gpApi))
            threeDs.set(for: "message_version", value: secureEcom.messageVersion)
            threeDs.set(for: "eci", value: secureEcom.eci)
            threeDs.set(for: "status", value: secureEcom.status)
            threeDs.set(for: "server_trans_ref", value: secureEcom.serverTransactionId)
            threeDs.set(for: "ds_trans_ref", value: secureEcom.directoryServerTransactionId)
            threeDs.set(for: "value", value: secureEcom.authenticationValue)
            authentication.set(for: "three_ds", doc: threeDs)
            
            paymentMethod.set(for: "authentication", doc: authentication)
        }

        paymentMethod.set(for: "fingerprint_mode", value: builder.customerData?.deviceFingerPrint)

        if modifier == TransactionModifier.encryptedMobile || modifier == TransactionModifier.decryptedMobile {
            let digitalWallet = JsonDoc()
            if modifier == TransactionModifier.encryptedMobile {
                if creditCardData.mobileType == EncryptedMobileType.CLICK_PAY.rawValue {
                    // CTP token is a plain numeric string wrapped in payment_token.data
                    let paymentToken = JsonDoc()
                    paymentToken.set(for: "data", value: creditCardData.token)
                    digitalWallet.set(for: "payment_token", doc: paymentToken)
                } else {
                    // Apple Pay / Google Pay tokens are JSON objects encoded as strings
                    let tokenDoc = JsonDoc.parse(creditCardData.token ?? "{}")
                    digitalWallet.set(for: "payment_token", doc: tokenDoc)
                }
            } else if modifier == TransactionModifier.decryptedMobile {
                let authBuilder = builder as? AuthorizationBuilder
                if let decryptionId = authBuilder?.decryptionId {
                    // CTP decrypt flow: PMT_ID goes in payment_method.id, DEC_ID in digital_wallet.decrypt.id
                    paymentMethod.set(for: "id", value: creditCardData.token)
                    let decryptDoc = JsonDoc()
                    decryptDoc.set(for: "id", value: decryptionId)
                    digitalWallet.set(for: "decrypt", doc: decryptDoc)
                    let paymentTokenDoc = JsonDoc()
                    paymentTokenDoc.set(for: "dpa_reference", value: creditCardData.dpaReference)
                    paymentTokenDoc.set(for: "data_type_indicator", value: creditCardData.dataTypeIndicator)
                    digitalWallet.set(for: "payment_token", doc: paymentTokenDoc)
                } else {
                    digitalWallet.set(for: "token", value: creditCardData.token)
                    digitalWallet.set(for: "token_format", value: DigitalWalletTokenFormat.CARD_NUMBER.rawValue)
                    digitalWallet.set(for: "expiry_month", value: CardUtils.getExpMonthFormat(creditCardData.expMonth))
                    digitalWallet.set(for: "expiry_year", value: CardUtils.getExpYearFormat(creditCardData.expYear))
                    digitalWallet.set(for: "cryptogram", value: creditCardData.cryptogram)
                    digitalWallet.set(for: "eci", value: creditCardData.eci)
                    digitalWallet.set(for: "avs_address", value: builder.billingAddress?.streetAddress1 ?? "")
                    digitalWallet.set(for: "avs_postal_code", value: builder.billingAddress?.postalCode ?? "")
                }
            }
            digitalWallet.set(for: "provider", value: creditCardData.mobileType)
            paymentMethod.set(for: "digital_wallet", doc: digitalWallet)
        }
    }

    private func encryptablePaymentMethod(_ paymentMethod: JsonDoc, encryptable: Encryptable) {
        if let encryptionData = encryptable.encryptionData {
            let encryption = JsonDoc()
                .set(for: "version", value: encryptionData.version)
                .set(for: "type", value: encryptionData.type as? any Encodable)
            if !encryptionData.ktb.isNilOrEmpty {
                encryption.set(for: "method", value: "KTB")
                encryption.set(for: "info", value: encryptionData.ktb)
            } else if !encryptionData.ksn.isNilOrEmpty {
                encryption.set(for: "method", value: "KSN")
                encryption.set(for: "info", value: encryptionData.ksn)
            }
            if encryption.has(key: "info") {
                paymentMethod.set(for: "encryption", doc: encryption)
            }
        }
    }
    
    private func alternatePaymentMethod(_ paymentMethod: JsonDoc, alternatePayment: AlternatePaymentMethod){
        paymentMethod.set(for: "name", value: alternatePayment.accountHolderName)

        let apm = JsonDoc()
        apm.set(for: "provider", value: alternatePayment.alternativePaymentMethodType?.mapped(for: .gpApi))
        apm.set(for: "address_override_mode", value: alternatePayment.addressOverrideMode)
        apm.set(for: "category", value: alternatePayment.category?.mapped(for: .gpApi))
        // Cashpresso payment plan (PAY_IN_3_INSTALLMENTS, PAY_30_DAYS)
        apm.set(for: "payment_plan", value: alternatePayment.paymentPlan?.mapped(for: .gpApi))
        // BLIK Level 0 fields
        apm.set(for: "mode", value: alternatePayment.blikMode?.mapped(for: .gpApi))
        apm.set(for: "payment_code_initiator", value: alternatePayment.paymentCodeInitiator?.mapped(for: .gpApi))
        apm.set(for: "payment_code", value: alternatePayment.paymentCode)
        if let terms = alternatePayment.terms {
            let termsDoc = JsonDoc()
            termsDoc.set(for: "time_unit", value: terms.TimeUnit)
            termsDoc.set(for: "count", value: terms.count.map { "\($0)" })
            termsDoc.set(for: "mode", value: terms.mode)
            apm.set(for: "terms", doc: termsDoc)
        }
        if alternatePayment.alternativePaymentMethodType == .OB {
            let bank = JsonDoc()
            bank.set(for: "name", value: alternatePayment.bank?.mapped(for: .gpApi))
            let bankTransfer = JsonDoc()
            bankTransfer.set(for: "bank", doc: bank)
            paymentMethod.set(for: "bank_transfer", doc: bankTransfer)
        }
        paymentMethod.set(for: "apm", doc: apm)
    }
    
    private func bnplPaymentMethod(bnpl: BNPL) -> JsonDoc {
        let bnplType = JsonDoc()
        bnplType.set(for: "provider", value: bnpl.BNPLType?.mapped(for: .gpApi))
        return bnplType
    }
    
    private func openBankingPaymentMethod(_ bankPaymentMethod: BankPayment, builder: Builder, paymentMethod: JsonDoc) {
        let apm = JsonDoc()
        apm.set(for: "provider", value: PaymentProvider.OPEN_BANKING.rawValue)
        apm.set(for: "countries", value: bankPaymentMethod.countries)
        paymentMethod.set(for: "apm", doc: apm)

        let bankPaymentType = bankPaymentMethod.bankPaymentType ?? CurrencyUtils.shared.getBankPaymentType(builder.currency ?? "")
        let bankTransfer = JsonDoc()
        bankTransfer.set(for: "account_number", value: bankPaymentType == .FASTERPAYMENTS ? bankPaymentMethod.accountNumber : "")
        bankTransfer.set(for: "iban", value: bankPaymentType == .SEPA ? bankPaymentMethod.iban : "")

        let bank = JsonDoc()
        bank.set(for: "code", value: bankPaymentMethod.sortCode)
        bank.set(for: "name", value: bankPaymentMethod.accountName)
        bankTransfer.set(for: "bank", doc: bank)

        let remittance = JsonDoc()
        remittance.set(for: "type", value: builder.remittanceReferenceType?.rawValue)
        remittance.set(for: "value", value: builder.remittanceReferenceValue)
        bankTransfer.set(for: "remittance_reference", doc: remittance)
        
        paymentMethod.set(for: "bank_transfer", doc: bankTransfer)
    }

    private func mapFraudManagement(_ builder: AuthorizationBuilder) -> [JsonDoc] {
        var rules = [JsonDoc]()
        if let fraudRules = builder.fraudRules {
            fraudRules.rules.forEach { rule in
                let doc = JsonDoc()
                doc.set(for: "reference", value: rule.key)
                doc.set(for: "mode", value: rule.mode?.rawValue)
                rules.append(doc)
            }
        }

        var result = [JsonDoc]()
        let item = JsonDoc()
        item.set(for: "mode", value: builder.fraudFilterMode?.rawValue)
        item.set(for: "rules", values: rules)
        result.append(item)
        return result
    }
    
    private func mapAllowedPaymentMethod(_ paymentMethods: [PaymentMethodName]?) -> [String?]? {
        return paymentMethods?.map {
            $0.mapped(for: .gpApi)
        }
    }

    private func setPayerInformation(_ builder: AuthorizationBuilder) -> JsonDoc {
        let payer = JsonDoc()
        payer.set(for: "id", value: builder.customerId ?? builder.customerData?.id)
        payer.set(for: "reference", value: builder.customerData?.key)

        if builder.paymentMethod is eCheck {
            payer.set(for: "billing_address", doc: getBasicAddressInformation(builder.billingAddress))

            if let customer = builder.customerData {
                payer.set(for: "name", value: "\(customer.firstName ?? "") \(customer.lastName ?? "")")
                payer.set(for: "date_of_birth", value: customer.dateOfBirth)
                payer.set(for: "landline_phone", value: customer.homePhone)
                payer.set(for: "mobile_phone", value: customer.mobilePhone)
            }
        } else if builder.paymentMethod is BNPL, let customerData = builder.customerData {
            payer.set(for: "email", value: customerData.email)
            payer.set(for: "date_of_birth", value: customerData.dateOfBirth)

            let billingAddress = getBasicAddressInformation(builder.billingAddress)
            billingAddress.set(for: "first_name", value: customerData.firstName)
            billingAddress.set(for: "last_name", value: customerData.lastName)

            payer.set(for: "billing_address", doc: billingAddress)
            
            if let numberPhone = customerData.phoneNumber {
                let homePhone = JsonDoc()
                homePhone.set(for: "country_code", value: numberPhone.countryCode)
                homePhone.set(for: "subscriber_number", value: numberPhone.number)
                payer.set(for: "contact_phone", doc: homePhone)
            }
            
            if let documents = customerData.documents {
                var jsonDocuments: [JsonDoc] = []
                
                documents.forEach {
                    let doc = JsonDoc()
                    doc.set(for: "type", value: $0.type?.mapped(for: .gpApi))
                    doc.set(for: "reference", value: $0.reference)
                    doc.set(for: "issuer", value: $0.issuer)
                    jsonDocuments.append(doc)
                }
                payer.set(for: "documents", values: jsonDocuments)
            }
        } else if builder.payByLinkData?.type == .hosted_payment_page {
            payer.set(for: "email", value: builder.customerData?.email)
                .set(for: "language", value: builder.customerData?.language)
                .set(for: "status", value: builder.customerData?.status)
                 let dataName = "\(builder.customerData?.firstName ?? "") \(builder.customerData?.lastName ?? "")"
            payer.set(for: "name", value: dataName)
                .set(for: "first_name", value: builder.customerData?.firstName)
                .set(for: "last_name", value: builder.customerData?.lastName)
                .set(for: "address_match_indicator", value: builder.customerData?.isShippingAddressSameAsBilling == true ? "YES" : "NO")
            
            payer.set(for: "billing_address", doc: getBasicAddressInformation(builder.billingAddress))
            
            if let phoneNumber = builder.customerData?.phoneNumber {
                let homePhone = setPhoneInformation(phoneNumber)
                payer.set(for: "mobile_phone", doc: homePhone)
            }
        }
        return payer
    }
    
    private func setOrderInformation(_ builder: AuthorizationBuilder, requestBody: JsonDoc) {
        var order = JsonDoc()
        if let orderDoc = requestBody.get(valueFor: "order") {
            order = orderDoc
        }
        
        order.set(for: "description", value: builder.orderDetails?.description)

        var shippingAddressDoc = JsonDoc()
        if let shippingAddress = builder.shippingAddress {
            shippingAddressDoc = getBasicAddressInformation(shippingAddress)
        }

        let shippingPhone = JsonDoc()
        shippingPhone.set(for: "country_code", value: builder.shippingPhone?.countryCode)
        shippingPhone.set(for: "subscriber_number", value: builder.shippingPhone?.number)
        order.set(for: "shipping_phone", doc: shippingPhone)

        order.set(for: "shipping_method", value: builder.bnplShippingMethod?.mapped(for: .gpApi))
        
        if let products = builder.miscProductData {
            order.set(for: "items", values: setItemDetailsListForBNPL(products, currency: builder.currency))
        }

        if let customerData = builder.customerData {
            shippingAddressDoc.set(for: "first_name", value: customerData.firstName)
            shippingAddressDoc.set(for: "last_name", value: customerData.lastName)
        }

        if !shippingAddressDoc.keys.isEmpty {
            order.set(for: "shipping_address", doc: shippingAddressDoc)
        }

        if let supplementaryDataList = builder.orderSupplementaryData {
            let supplementaryDataDocs = supplementaryDataList.map { item -> JsonDoc in
                let doc = JsonDoc()
                doc.set(for: "type", value: item.type)
                doc.set(for: "fields", value: item.fields)
                return doc
            }
            order.set(for: "supplementary_data", values: supplementaryDataDocs)
        } else {
            order.set(for: "supplementary_data", values: nil)
        }
        
        if (!requestBody.has(key: "order") && !order.keys.isEmpty) {
            requestBody.set(for: "order", doc: order)
        }
    }

    /// Builds the `order` block for a Cashpresso /transactions request.
    /// Includes: tax_amount, shipping_date (mandatory), shipping_method, shipping_address, items.
    private func setCashpressoOrderInformation(_ builder: AuthorizationBuilder, requestBody: JsonDoc) {
        let order = JsonDoc()
        if let taxAmount = builder.orderTaxAmount {
            order.set(for: "tax_amount", value: NSDecimalNumber(decimal: taxAmount).toNumericCurrencyString(currency: builder.currency))
        }
        order.set(for: "shipping_date", value: builder.shippingDate)
        order.set(for: "shipping_method", value: builder.bnplShippingMethod?.mapped(for: .gpApi))

        if let shippingAddress = builder.shippingAddress {
            order.set(for: "shipping_address", doc: getBasicAddressInformation(shippingAddress))
        }

        if let products = builder.miscProductData, !products.isEmpty {
            order.set(for: "items", values: setItemDetailsListForCashpresso(products, currency: builder.currency))
        }

        if !order.keys.isEmpty {
            requestBody.set(for: "order", doc: order)
        }
    }

    /// Serialises order items for a Cashpresso /transactions request.
    /// Maps: description, reference, quantity, unit_amount, tax_amount.
    private func setItemDetailsListForCashpresso(_ products: [Product], currency: String? = nil) -> [JsonDoc] {
        return products.map { product in
            let item = JsonDoc()
            item.set(for: "description", value: product.descriptionProduct)
            item.set(for: "reference", value: product.productId)
            item.set(for: "quantity", value: "\(product.quantity ?? 0)")
            item.set(for: "unit_amount", value: (product.unitPrice ?? 0).toNumericCurrencyString(currency: currency))
            item.set(for: "tax_amount", value: (product.taxAmount ?? 0).toNumericCurrencyString(currency: currency))
            return item
        }
    }

    /// Serialises order items for a Cashpresso HPP /links request.
    /// Maps: label (productName), product_code (productId), quantity, unit_amount, tax_amount.
    private func setItemDetailsListForHPP(_ products: [Product], currency: String? = nil) -> [JsonDoc] {
        return products.map { product in
            let item = JsonDoc()
            item.set(for: "label", value: product.productName)
            item.set(for: "product_code", value: product.productId)
            item.set(for: "quantity", value: "\(product.quantity ?? 0)")
            item.set(for: "unit_amount", value: (product.unitPrice ?? 0).toNumericCurrencyString(currency: currency))
            item.set(for: "tax_amount", value: (product.taxAmount ?? 0).toNumericCurrencyString(currency: currency))
            return item
        }
    }

    private func setItemDetailsListForBNPL(_ products: [Product], currency: String? = nil) -> [JsonDoc] {
        var items: [JsonDoc] = []
        products.forEach { product in
            let item = JsonDoc()
            let taxAmount = product.taxAmount ?? 0
            let unitAmount = product.unitPrice ?? 0
            let qty = product.quantity ?? 0
            let totalAmount = NSDecimalNumber(value: Double(qty) * unitAmount.doubleValue)
            let netUnitAmount = product.netUnitAmount ?? 0
            let discountAmount = product.discountAmount ?? 0
            item.set(for: "reference", value: product.productId)
            item.set(for: "label", value: product.productName)
            item.set(for: "description", value: product.descriptionProduct)
            item.set(for: "quantity", value: "\(qty)")
            item.set(for: "unit_amount", value: unitAmount.toNumericCurrencyString(currency: currency))
            item.set(for: "total_amount", value: totalAmount.toNumericCurrencyString(currency: currency))
            item.set(for: "tax_amount", value: taxAmount.toNumericCurrencyString(currency: currency))
            item.set(for: "discount_amount", value: discountAmount.toNumericCurrencyString(currency: currency))
            item.set(for: "tax_percentage", value: product.taxPercentage?.toNumericCurrencyString(currency: currency))
            item.set(for: "net_unit_amount", value: netUnitAmount.toNumericCurrencyString(currency: currency))
            item.set(for: "gift_card_currency", value: product.giftCardCurrency)
            item.set(for: "url", value: product.url)
            item.set(for: "image_url", value: product.imageUrl)
            items.append(item)
        }
        return items
    }
    
    private func getBasicAddressInformation(_ address: Address?) -> JsonDoc {
        let basicAddress = JsonDoc()
        basicAddress.set(for: "line_1", value: address?.streetAddress1)
        basicAddress.set(for: "line_2", value: address?.streetAddress2)
        basicAddress.set(for: "line_3", value: address?.streetAddress3)
        basicAddress.set(for: "city", value: address?.city)
        basicAddress.set(for: "postal_code", value: address?.postalCode)
        basicAddress.set(for: "state", value: address?.state)
        basicAddress.set(for: "country", value: address?.countryCode)
        return basicAddress
    }
    
    private func setERatyPayerInformation(_ builder: AuthorizationBuilder) -> JsonDoc {
        let payer = JsonDoc()
        payer.set(for: "reference", value: builder.customerId ?? builder.customerData?.key)
        payer.set(for: "country", value: builder.payerDetails?.country ?? builder.billingAddress?.countryCode)
        payer.set(for: "email", value: builder.payerDetails?.email ?? builder.customerData?.email)
        return payer
    }

    /// Builds the `payer` object for a Cashpresso /transactions request.
    /// Structure: email, billing_address (line_1..3, city, postal_code, state, country), home_phone.
    private func setCashpressoPayerInformation(_ builder: AuthorizationBuilder) -> JsonDoc {
        let payer = JsonDoc()
        payer.set(for: "email", value: builder.payerDetails?.email ?? builder.customerData?.email)

        let billingAddress = getBasicAddressInformation(builder.billingAddress)
        payer.set(for: "billing_address", doc: billingAddress)

        if let phone = builder.homePhone {
            let homePhone = JsonDoc()
            homePhone.set(for: "country_code", value: phone.countryCode)
            homePhone.set(for: "subscriber_number", value: phone.number)
            payer.set(for: "home_phone", doc: homePhone)
        }
        return payer
    }

    /// Builds the `payer` object for a BLIK Level 0 /transactions request.
    /// Structure: first_name, last_name, email, ip_address, user_agent.
    private func setBlikPayerInformation(_ builder: AuthorizationBuilder) -> JsonDoc {
        let apm = builder.paymentMethod as? AlternatePaymentMethod
        let payer = JsonDoc()
        payer.set(for: "first_name", value: builder.customerData?.firstName)
        payer.set(for: "last_name", value: builder.customerData?.lastName)
        payer.set(for: "email", value: builder.customerData?.email)
        payer.set(for: "ip_address", value: builder.customerIpAddress)
        payer.set(for: "user_agent", value: builder.customerUserAgent ?? apm?.userAgent)
        return payer
    }

    private func setNotificationUrls(_ paymentMethod: PaymentMethod?) -> JsonDoc {
        let notifications = JsonDoc()
        if let paymentMethod = paymentMethod as? NotificationData {
            notifications.set(for: "return_url", value: paymentMethod.returnUrl)
            notifications.set(for: "status_url", value: paymentMethod.statusUpdateUrl)
            notifications.set(for: "cancel_url", value: paymentMethod.cancelUrl)
        }
        return notifications
    }
    
    private func setInstallmentData(_ installmentData: InstallmentData) -> JsonDoc? {
        let installment = JsonDoc()
        installment.set(for: "program", value: installmentData.program)
        installment.set(for: "mode", value: installmentData.mode)
        installment.set(for: "count", value: installmentData.count)
        installment.set(for: "grace_period_count", value: installmentData.gracePeriodCount)
        return installment
    }
    
    private func setPhoneInformation(_ phoneNumber: PhoneNumber) -> JsonDoc {
        let phoneInfo = JsonDoc()
            .set(for: "country_code", value: phoneNumber.countryCode)
            .set(for: "subscriber_number", value: phoneNumber.number)
        return phoneInfo
    }

    /// Validates Cashpresso-specific constraints before the request is sent.
    /// Throws `UnsupportedTransactionException` on any constraint violation.
    func validateCashpresso(builder: AuthorizationBuilder, config: GpApiConfig?) throws {
        guard let apm = builder.paymentMethod as? AlternatePaymentMethod,
              apm.alternativePaymentMethodType == .CASHPRESSO else {
            return
        }

        guard apm.paymentPlan != nil else {
            throw UnsupportedTransactionException(message: "Cashpresso requires payment_plan.")
        }

        guard builder.bnplShippingMethod != nil else {
            throw UnsupportedTransactionException(message: "Cashpresso requires shipping_method.")
        }

        guard builder.shippingDate != nil else {
            throw UnsupportedTransactionException(message: "Cashpresso requires shipping_date.")
        }

        let country = config?.country?.uppercased() ?? ""
        guard country == "DE" || country == "AT" else {
            throw UnsupportedTransactionException(message: "Cashpresso is only supported for GPAPI country DE or AT.")
        }

        if apm.paymentPlan == .PAY_IN_3_INSTALLMENTS {
            let amountMinorUnits = (builder.amount?.doubleValue ?? 0) * 100
            guard amountMinorUnits >= 15000 else {
                throw UnsupportedTransactionException(message: "Cashpresso PAY_IN_3_INSTALLMENTS requires amount of 15000 or more (minor units).")
            }
        }
    }

    /// Validates BLIK Level 0-specific constraints before the request is sent.
    /// Throws `UnsupportedTransactionException` on any constraint violation.
    func validateBlikLevelZero(builder: AuthorizationBuilder, config: GpApiConfig?) throws {
        guard let apm = builder.paymentMethod as? AlternatePaymentMethod,
              apm.alternativePaymentMethodType == .BLIK else {
            return
        }

        let anyLevelZeroFieldSet = apm.paymentCodeInitiator != nil || apm.paymentCode != nil
        guard apm.blikMode == .levelZero || anyLevelZeroFieldSet else {
            return
        }

        guard apm.blikMode == .levelZero else {
            throw UnsupportedTransactionException(message: "Blik Level 0 requires paymentMethod.blikMode to be set to .levelZero.")
        }

        guard apm.paymentCodeInitiator != nil else {
            throw UnsupportedTransactionException(message: "Blik Level 0 requires payment_code_initiator.")
        }

        guard let paymentCode = apm.paymentCode, !paymentCode.isEmpty else {
            throw UnsupportedTransactionException(message: "Blik Level 0 requires payment_code.")
        }

        guard paymentCode.range(of: "^\\d{6}$", options: .regularExpression) != nil else {
            throw UnsupportedTransactionException(message: "paymentMethod.paymentCode must be exactly 6 digits for BLIK Level 0 transactions.")
        }

        guard !(builder.customerIpAddress?.isEmpty ?? true) else {
            throw UnsupportedTransactionException(message: "customerIpAddress cannot be null for BLIK Level 0 transactions.")
        }

        guard !((builder.customerUserAgent ?? apm.userAgent)?.isEmpty ?? true) else {
            throw UnsupportedTransactionException(message: "customerUserAgent cannot be null for BLIK Level 0 transactions.")
        }
    }
}

