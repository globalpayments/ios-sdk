import Foundation

struct GpApiAuthorizationRequestBuilder: GpApiRequestData {

    func generateRequest(for builder: AuthorizationBuilder, config: GpApiConfig?) -> GpApiRequest? {
        let merchantUrl: String = !(config?.merchantId?.isEmpty ?? true) ? "/merchants/\(config?.merchantId ?? "")" : .empty
        switch builder.transactionType {
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
            payload.set(for: "amount", value: builder.amount?.toNumericCurrencyString())
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
            if let payLinkData = builder.payLinkData {
                payload.set(for: "usage_limit", value: payLinkData.usageLimit)
                payload.set(for: "usage_mode", value: payLinkData.usageMode?.mapped(for: .gpApi))
                payload.set(for: "images", value: payLinkData.images)
                payload.set(for: "description", value: builder.requestDescription)
                payload.set(for: "type", value: payLinkData.type?.mapped(for: .gpApi))
                payload.set(for: "expiration_date", value: payLinkData.expirationDate?.format("yyyy-MM-dd"))
                
                let transaction = JsonDoc()
                transaction.set(for: "country", value: config?.country)
                transaction.set(for: "amount", value: builder.amount?.toNumericCurrencyString())
                transaction.set(for: "channel", value: config?.channel.mapped(for: .gpApi))
                transaction.set(for: "currency", value: builder.currency)
                transaction.set(for: "allowed_payment_methods", value: mapAllowedPaymentMethod(payLinkData.allowedPaymentMethods))
                
                payload.set(for: "transactions", doc: transaction)
                payload.set(for: "reference", value: builder.clientTransactionId)
                payload.set(for: "shipping_amount", value: payLinkData.shippingAmount?.toNumericCurrencyString())
                payload.set(for: "shippable", value: payLinkData.isShippable ?? false ? "YES" : "NO")
                payload.set(for: "account_name", value: config?.accessTokenInfo?.transactionProcessingAccountName)
                payload.set(for: "name", value: payLinkData.name)
                
                let notification = JsonDoc()
                notification.set(for: "cancel_url", value: payLinkData.cancelUrl)
                notification.set(for: "return_url", value: payLinkData.returnUrl)
                notification.set(for: "status_url", value: payLinkData.statusUpdateUrl)

                payload.set(for: "notifications", doc: notification)
                payload.set(for: "status", value: payLinkData.status?.mapped(for: .gpApi))
            }
            
            return GpApiRequest(
                endpoint: merchantUrl + "/links",
                method: .post,
                requestBody: payload.toString()
            )
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
            .set(for: "amount", value: builder.amount?.toNumericCurrencyString())
            .set(for: "currency", value: builder.currency)
            .set(for: "reference", value: builder.clientTransactionId ?? UUID().uuidString)
            .set(for: "description", value: builder.requestDescription)
            .set(for: "gratuity_amount", value: builder.gratuity?.toNumericCurrencyString())
            .set(for: "surcharge_amount", value: builder.surchargeAmount?.toNumericCurrencyString())
            .set(for: "convenience_amount", value: builder.convenienceAmount?.toNumericCurrencyString())
            .set(for: "cashback_amount", value: builder.cashBackAmount?.toNumericCurrencyString())
            .set(for: "ip_address", value: builder.customerIpAddress)
            .set(for: "payment_method", doc: createPaymentMethodParam(for: builder, channel: config?.channel))
            .set(for: "risk_assessment", values: builder.fraudFilterMode != nil ? mapFraudManagement(builder) : nil)
            .set(for: "link", doc: JsonDoc().set(for: "id", value: builder.paymentLinkId))

        if let dccId = builder.dccRateData?.dccId, !dccId.isEmpty {
            let currencyDoc = JsonDoc()
            currencyDoc.set(for: "id", value: dccId)
            payload.set(for: "currency_conversion", doc: currencyDoc)
        }
        
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
            payload.set(for: "stored_credential", doc: storedCredential)
        }

        if builder.paymentMethod is eCheck || builder.paymentMethod is BNPL {
            payload.set(for: "payer", doc: setPayerInformation(builder))
        }
        
        if builder.paymentMethod is BNPL {
            setOrderInformation(builder, requestBody: payload)
        }
        
        if builder.paymentMethod is AlternatePaymentMethod || builder.paymentMethod is BNPL || builder.paymentMethod is BankPayment {
            payload.set(for:"notifications", doc: setNotificationUrls(builder.paymentMethod))
        }
        
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
                        return PaymentEntryMode.contactlessSwipe.rawValue
                    }
                    if let emvData = EmvUtils.shared.parseTagData(builder.tagData) {
                        if emvData.isContactlessMsd() {
                            return PaymentEntryMode.contactlessSwipe.rawValue
                        }
                        return PaymentEntryMode.chip.rawValue
                    }
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
            }

            if builder.transactionModifier == .encryptedMobile,
               let creditCard = builder.paymentMethod as? CreditCardData,
               creditCard.hasInAppPaymentData() {
                return PaymentEntryMode.inApp.rawValue
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
            bankTransfer.set(for: "narrative", value: check.merchantNotes)

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
        }else {
            
            if let creditCard = builder.paymentMethod as? CreditCardData, let token = creditCard.token {
                hasToken = !token.isEmpty
            }
            
            if !hasToken {
                paymentMethod.set(for: "card", doc: CardUtils.generateCard(builder: builder))
            }
            
            let brandReferenceDoc = JsonDoc()
            brandReferenceDoc.set(for: "brand_reference", value: builder.cardBrandTransactionId)
            paymentMethod.set(for: "card", doc: brandReferenceDoc)
        }

        paymentMethod.set(for: "narrative", value: builder.dynamicDescriptor)

        return paymentMethod
    }

    private func creditCardDataPaymentMethod(_ paymentMethod: JsonDoc, modifier: TransactionModifier, creditCardData: CreditCardData, builder: Builder) {
        paymentMethod.set(for: "name", value: creditCardData.cardHolderName)

        if let secureEcom = creditCardData.threeDSecure {
            paymentMethod.set(for: "authentication.id", value: secureEcom.serverTransactionId)
        }

        paymentMethod.set(for: "fingerprint_mode", value: builder.customerData?.deviceFingerPrint)

        if modifier == TransactionModifier.encryptedMobile || modifier == TransactionModifier.decryptedMobile {
            let digitalWallet = JsonDoc()
            if modifier == TransactionModifier.encryptedMobile {
                let cardData = JsonDoc()
                cardData.set(for: "data", value: creditCardData.token)
                digitalWallet.set(for: "payment_token", doc: cardData)
            } else if modifier == TransactionModifier.decryptedMobile {
                digitalWallet.set(for: "token", value: creditCardData.token)
                digitalWallet.set(for: "token_format", value: DigitalWalletTokenFormat.CARD_NUMBER.rawValue)
                digitalWallet.set(for: "expiry_month", value: CardUtils.getExpMonthFormat(creditCardData.expMonth))
                digitalWallet.set(for: "expiry_year", value: CardUtils.getExpYearFormat(creditCardData.expYear))
                digitalWallet.set(for: "cryptogram", value: creditCardData.cryptogram)
                digitalWallet.set(for: "eci", value: creditCardData.eci)
            }
            digitalWallet.set(for: "provider", value: creditCardData.mobileType)
            paymentMethod.set(for: "digital_wallet", doc: digitalWallet)
        }
    }

    private func encryptablePaymentMethod(_ paymentMethod: JsonDoc, encryptable: Encryptable) {
        if let encryptionData = encryptable.encryptionData {
            let encryption = JsonDoc()
                .set(for: "version", value: encryptionData.version)
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
        payer.set(for: "reference", value: builder.customerId ?? builder.customerData?.id)

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
            order.set(for: "items", values: setItemDetailsListForBNPL(products))
        }

        if let customerData = builder.customerData {
            shippingAddressDoc.set(for: "first_name", value: customerData.firstName)
            shippingAddressDoc.set(for: "last_name", value: customerData.lastName)
        }

        if !shippingAddressDoc.keys.isEmpty {
            order.set(for: "shipping_address", doc: shippingAddressDoc)
        }

        if (!requestBody.has(key: "order") && !order.keys.isEmpty) {
            requestBody.set(for: "order", doc: order)
        }
    }
    
    private func setItemDetailsListForBNPL(_ products: [Product]) -> [JsonDoc] {
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
            item.set(for: "unit_amount", value: unitAmount.toNumericCurrencyString())
            item.set(for: "total_amount", value: totalAmount.toNumericCurrencyString())
            item.set(for: "tax_amount", value: taxAmount.toNumericCurrencyString())
            item.set(for: "discount_amount", value: discountAmount.toNumericCurrencyString())
            item.set(for: "tax_percentage", value: product.taxPercentage?.toNumericCurrencyString())
            item.set(for: "net_unit_amount", value: netUnitAmount.toNumericCurrencyString())
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
    
    private func setNotificationUrls(_ paymentMethod: PaymentMethod?) -> JsonDoc {
        let notifications = JsonDoc()
        if let paymentMethod = paymentMethod as? NotificationData {
            notifications.set(for: "return_url", value: paymentMethod.returnUrl)
            notifications.set(for: "status_url", value: paymentMethod.statusUpdateUrl)
            notifications.set(for: "cancel_url", value: paymentMethod.cancelUrl)
        }
        return notifications
    }
}
