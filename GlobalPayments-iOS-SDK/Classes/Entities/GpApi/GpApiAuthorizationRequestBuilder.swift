import Foundation

struct GpApiAuthorizationRequestBuilder: GpApiRequestData {

    func generateRequest(for builder: AuthorizationBuilder, config: GpApiConfig?) -> GpApiRequest? {

        switch builder.transactionType {
        case .sale, .refund, .auth:
            let payload = createFromAuthorizationBuilder(builder, config)
            return GpApiRequest(
                endpoint: GpApiRequest.Endpoints.transactions(),
                method: .post,
                requestBody: payload.toString()
            )
        case .verify:
            if builder.requestMultiUseToken == true && ((builder.paymentMethod as? Tokenizable)?.token == nil) {
                let payload = createForVerify(builder, config)
                return GpApiRequest(
                    endpoint: GpApiRequest.Endpoints.paymentMethods(),
                    method: .post,
                    requestBody: payload.toString()
                )
            } else {
                let payload = generateVerificationRequest(builder, config)
                return GpApiRequest(
                    endpoint: GpApiRequest.Endpoints.verify(),
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
            .set(for: "link", doc: JsonDoc().set(for: "id", value: builder.paymentLinkId))

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
        
        switch(builder.paymentMethod){
        case let creditCardData as CreditCardData:
            creditCardDataPaymentMethod(paymentMethod, modifier: builder.transactionModifier, creditCardData: creditCardData, builder: builder)
            break
        case let encryptable as Encryptable:
            encryptablePaymentMethod(paymentMethod, encryptable: encryptable)
            break
        case .none, .some(_): break
        }
        
        if let tokenizable = builder.paymentMethod as? Tokenizable, builder.transactionModifier != .encryptedMobile, builder.transactionModifier != .decryptedMobile {
            if let token = tokenizable.token, !token.isEmpty {
                paymentMethod.set(for: "id", value: token)
            }
        }

        if builder.requestMultiUseToken == true {
            paymentMethod.set(for: "storage_mode", value: "ON_SUCCESS")
        }
        
        if paymentMethod.getValue(key: "id") == nil {
            paymentMethod.set(for: "card", doc: CardUtils.generateCard(builder: builder))
        }
        return paymentMethod
    }
    
    private func creditCardDataPaymentMethod(_ paymentMethod: JsonDoc, modifier: TransactionModifier, creditCardData: CreditCardData, builder: Builder){
        paymentMethod.set(for: "name", value: creditCardData.cardHolderName)
        
        if let secureEcom = creditCardData.threeDSecure {
            paymentMethod.set(for: "authentication.id",value: secureEcom.serverTransactionId)
        }
        
        paymentMethod.set(for: "fingerprint_mode", value: builder.customerData?.deviceFingerPrint)
        
        if modifier == TransactionModifier.encryptedMobile || modifier == TransactionModifier.decryptedMobile {
            let digitalWallet = JsonDoc()
            if modifier == TransactionModifier.encryptedMobile {
                let jsonToken = JsonDoc.parse(creditCardData.token ?? "{}")
                digitalWallet.set(for: "payment_token", doc: jsonToken)
            }else if modifier == TransactionModifier.decryptedMobile{
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
    
    private func encryptablePaymentMethod(_ paymentMethod: JsonDoc, encryptable: Encryptable){
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
}
