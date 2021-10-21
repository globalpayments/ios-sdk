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
            .set(for: "payment_method", doc: createPaymentMethodParam(for: builder))

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
            .set(for: "payment_method", doc: createPaymentMethodParam(for: builder))

        return payload
    }

    private func entryMode(for builder: Builder) -> String {
        if let card = builder.paymentMethod as? CardData {
            if card.readerPresent {
                return card.cardPresent ? PaymentEntryMode.manual.rawValue : PaymentEntryMode.inApp.rawValue
            } else {
                return card.cardPresent ? PaymentEntryMode.manual.rawValue : PaymentEntryMode.ecom.rawValue
            }
        } else if let track = builder.paymentMethod as? TrackData {
            if builder.tagData != nil {
                return track.entryMethod == .swipe ? PaymentEntryMode.chip.rawValue : PaymentEntryMode.contactlessChip.rawValue
            } else if builder.hasEmvFallbackData {
                return PaymentEntryMode.contactlessSwipe.rawValue
            }
            return PaymentEntryMode.swipe.rawValue
        }
        return PaymentEntryMode.ecom.rawValue
    }

    private func captureMode(for builder: Builder) -> String {
        if builder.multiCapture {
            return CaptureMode.multiple.rawValue
        } else if builder.transactionType == .auth {
            return CaptureMode.later.rawValue
        }
        return CaptureMode.auto.rawValue
    }

    private func createPaymentMethodParam(for builder: Builder) -> JsonDoc {
        let paymentMethod = JsonDoc()
        paymentMethod.set(for: "entry_mode", value: entryMode(for: builder))

        // Authentication
        if let creditCardData = builder.paymentMethod as? CreditCardData {
            paymentMethod.set(for: "name", value: creditCardData.cardHolderName)

            if let secureEcom = creditCardData.threeDSecure {
                paymentMethod.set(for: "id",value: secureEcom.serverTransactionId)
            }
        }

        // Encryption
        if let encryptable = builder.paymentMethod as? Encryptable,
           let encryptionData = encryptable.encryptionData {
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

        // Tokenized Payment Method
        if let tokenizable = builder.paymentMethod as? Tokenizable,
           let token = tokenizable.token, !token.isEmpty {
            paymentMethod.set(for: "id", value: token)
        }

        if builder.requestMultiUseToken == true {
            paymentMethod.set(for: "storage_model", value: "ON_SUCCESS")
        }

        if paymentMethod.getValue(key: "id") == nil {
            paymentMethod.set(for: "card", doc: CardUtils.generateCard(builder: builder))
        }

        return paymentMethod
    }
}
