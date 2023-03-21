import Foundation

struct GpApiAuthorizationRequestBuilder: GpApiRequestData {

    func generateRequest(for builder: AuthorizationBuilder, config: GpApiConfig?) -> GpApiRequest? {
        let merchantUrl: String = !(config?.merchantId?.isEmpty ?? true) ? "/merchants/\(config?.merchantId ?? "")" : ""
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
        default:
            return nil
        }
    }

    private func createFromAuthorizationBuilder(_ builder: AuthorizationBuilder, _ config: GpApiConfig?) -> JsonDoc {
        let payload = JsonDoc()
            .set(for: "account_name", value: config?.accessTokenInfo?.transactionProcessingAccountName)
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

        if builder.paymentMethod is eCheck {
            payload.set(for: "payer", doc: setPayerInformation(builder))
        }

        return payload
    }

    private func createForVerify(_ builder: AuthorizationBuilder, _ config: GpApiConfig?) -> JsonDoc {
        let payload = JsonDoc()
            .set(for: "account_name", value: config?.accessTokenInfo?.tokenizationAccountName)
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
        case .none, .some: break
        }

        if let tokenizable = builder.paymentMethod as? Tokenizable, builder.transactionModifier != .encryptedMobile, builder.transactionModifier != .decryptedMobile {
            if let token = tokenizable.token, !token.isEmpty {
                paymentMethod.set(for: "id", value: token)
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
            if paymentMethod.getValue(key: "id") == nil {
                paymentMethod.set(for: "card", doc: CardUtils.generateCard(builder: builder))
            }
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
                let jsonToken = JsonDoc.parse(creditCardData.token ?? "{}")
                digitalWallet.set(for: "payment_token", doc: jsonToken)
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

    private func setPayerInformation(_ builder: AuthorizationBuilder) -> JsonDoc {
        let payer = JsonDoc()
        payer.set(for: "reference", value: builder.customerId ?? builder.customerData?.id)

        if builder.paymentMethod is eCheck {
            let billingAddress = JsonDoc()
            billingAddress.set(for: "line_1", value: builder.billingAddress?.streetAddress1)
            billingAddress.set(for: "line_2", value: builder.billingAddress?.streetAddress2)
            billingAddress.set(for: "city", value: builder.billingAddress?.city)
            billingAddress.set(for: "postal_code", value: builder.billingAddress?.postalCode)
            billingAddress.set(for: "state", value: builder.billingAddress?.state)
            billingAddress.set(for: "country", value: builder.billingAddress?.countryCode)
            payer.set(for: "billing_address", doc: billingAddress)

            if let customer = builder.customerData {
                payer.set(for: "name", value: "\(customer.firstName ?? "") \(customer.lastName ?? "")")
                payer.set(for: "date_of_birth", value: customer.dateOfBirth)
                payer.set(for: "landline_phone", value: customer.homePhone)
                payer.set(for: "mobile_phone", value: customer.mobilePhone)
            }
        }
        return payer
    }
}
