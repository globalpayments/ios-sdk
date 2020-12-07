import Foundation

extension GpApiConnector {

    func processAuthorization(_ builder: AuthorizationBuilder,
                              completion: ((Transaction?, Error?) -> Void)?) {

        verifyAuthentication { [weak self] error in
            if let error = error {
                completion?(nil, error)
                return
            }

            let paymentMethod = JsonDoc()
            paymentMethod.set(for: "entry_mode", value: self?.entryMode(for: builder))

            if let cardData = builder.paymentMethod as? CardData {
                let card = JsonDoc()
                    .set(for: "number", value: cardData.number)
                    .set(for: "expiry_month", value: cardData.expMonth > .zero ? "\(cardData.expMonth)".leftPadding(toLength: 2, withPad: "0") : nil)
                    .set(for: "expiry_year", value: cardData.expYear > .zero ? "\(cardData.expYear)".leftPadding(toLength: 4, withPad: "0").substring(with: 2..<4) : nil)
                    //                .set(for: "track", value: "")
                    .set(for: "tag", value: builder.tagData)
                    .set(for: "cvv", value: cardData.cvn)
                    .set(for: "cvv_indicator", value: cardData.cvnPresenceIndicator.mapped(for: .gpApi))
                    .set(for: "avs_address", value: builder.billingAddress?.streetAddress1)
                    .set(for: "avs_postal_code", value: builder.billingAddress?.postalCode)
                    .set(for: "funding", value: builder.paymentMethod?.paymentMethodType == .debit ? "DEBIT" : "CREDIT")
                    .set(for: "authcode", value: builder.offlineAuthCode)
                //                .set(for: "brand_reference", value: "")

                if builder.emvLastChipRead != nil {
                    card.set(for: "chip_condition", value: builder.emvLastChipRead?.mapped(for: .gpApi))
                }

                if cardData.cvnPresenceIndicator == .present ||
                    cardData.cvnPresenceIndicator == .illegible ||
                    cardData.cvnPresenceIndicator == .notOnCard {
                    card.set(for: "cvv_indicator", value: cardData.cvnPresenceIndicator.mapped(for: .gpApi))
                }

                paymentMethod.set(for: "card", doc: card)

                if builder.transactionType == .verify {
                    if let requestMultiUseToken = builder.requestMultiUseToken,
                       requestMultiUseToken == true {
                        guard let tokenizationAccountName = self?.tokenizationAccountName else {
                            completion?(nil, GatewayException(message: "tokenizationAccountName is not set"))
                            return
                        }
                        let tokenizationData = JsonDoc()
                            .set(for: "account_name", value: tokenizationAccountName)
                            .set(for: "reference", value: builder.clientTransactionId ?? UUID().uuidString)
                            .set(for: "name", value: "")
                            .set(for: "card", doc: card)

                        self?.doTransaction(
                            method: .post,
                            endpoint: Endpoints.paymentMethods(),
                            data: tokenizationData.toString(),
                            idempotencyKey: nil) { response, error in
                            guard let tokenizationResponse = response else {
                                completion?(nil, error)
                                return
                            }
                            let doc = JsonDoc.parse(tokenizationResponse)
                            let transaction = GpApiMapping.mapTransaction(doc)
                            completion?(transaction, nil)
                            return
                        }
                        return
                    } else {

                        if let paymentMethod = builder.paymentMethod as? Tokenizable,
                           let token = paymentMethod.token {

                            self?.doTransaction(
                                method: .get,
                                endpoint: Endpoints.paymentMethodsWith(token: token),
                                idempotencyKey: nil) { response, error in
                                guard let tokenizationResponse = response else {
                                    completion?(nil, error)
                                    return
                                }
                                let doc = JsonDoc.parse(tokenizationResponse)
                                let transaction = GpApiMapping.mapTransaction(doc)
                                completion?(transaction, nil)
                                return
                            }
                            return
                        } else {
                            paymentMethod.set(for: "first_name", value: builder.firstName)
                            paymentMethod.set(for: "last_name", value: builder.lastName)
                            paymentMethod.set(for: "id", value: builder.id)

                            let verificationData = JsonDoc()
                                .set(for: "account_name", value: self?.transactionProcessingAccountName)
                                .set(for: "channel", value: self?.channel?.mapped(for: .gpApi))
                                .set(for: "currency", value: builder.currency)
                                .set(for: "country", value: builder.billingAddress?.country ?? self?.country)
                                .set(for: "payment_method", doc: paymentMethod)

                            if builder.clientTransactionId.isNilOrEmpty {
                                verificationData.set(for: "reference", value: UUID().uuidString)
                            } else {
                                verificationData.set(for: "reference", value: builder.clientTransactionId)
                            }

                            self?.doTransaction(
                                method: .post,
                                endpoint: Endpoints.verify(),
                                data: verificationData.toString(),
                                idempotencyKey: nil) { response, error in
                                guard let tokenizationResponse = response else {
                                    completion?(nil, error)
                                    return
                                }
                                let doc = JsonDoc.parse(tokenizationResponse)
                                let transaction = GpApiMapping.mapTransaction(doc)
                                completion?(transaction, nil)
                                return
                            }
                            return
                        }
                    }
                }

            } else if let track = builder.paymentMethod as? TrackData {
                let card = JsonDoc()
                    .set(for: "track", value: track.value)
                    .set(for: "tag", value: builder.tagData)
                    //                .set(for: "cvv", value: "")
                    //                .set(for: "cvv_indicator", value: "")
                    .set(for: "avs_address", value: builder.billingAddress?.streetAddress1)
                    .set(for: "avs_postal_code", value: builder.billingAddress?.postalCode)
                    .set(for: "authcode", value: builder.offlineAuthCode)
                //                .set(for: "brand_reference", value: "")
                if builder.transactionType == .sale {
                    card.set(for: "number", value: track.pan)
                    card.set(for: "expiry_month", value: track.expiry!.substring(with: 2..<4))
                    card.set(for: "expiry_year", value: track.expiry!.substring(with: 0..<2))
                    card.set(for: "chip_condition", value: builder.emvLastChipRead?.mapped(for: .gpApi))
                    card.set(for: "funding", value: builder.paymentMethod?.paymentMethodType == .debit ? "DEBIT" : "CREDIT")
                }

                paymentMethod.set(for: "card", doc: card)
            }

            // Tokenized Payment Method
            if let tokenizable = builder.paymentMethod as? Tokenizable,
               let token = tokenizable.token, !token.isEmpty {
                paymentMethod.set(for: "id", value: token)
            }

            // PIN Block
            if let pinProtected = builder.paymentMethod as? PinProtected {
                paymentMethod
                    .get(valueFor: "card")?
                    .set(for: "pin_block", value: pinProtected.pinBlock)
            }

            // Authentication
            if let creditCardData = builder.paymentMethod as? CreditCardData {
                paymentMethod.set(for: "name", value: creditCardData.cardHolderName)

                if let secureEcom = creditCardData.threeDSecure {
                    let authentication = JsonDoc()
                        .set(for: "xid", value: secureEcom.xid)
                        .set(for: "cavv", value: secureEcom.cavv)
                        .set(for: "eci", value: String(secureEcom.eci ?? .zero))
                    //                    .set(for: "mac", value: "") //A message authentication code submitted to confirm integrity of the request.
                    paymentMethod.set(for: "authentication", doc: authentication)
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

            guard let transactionProcessingAccountName = self?.transactionProcessingAccountName else {
                completion?(nil, GatewayException(message: "transactionProcessingAccountName is not set"))
                return
            }

            let data = JsonDoc()
                .set(for: "account_name", value: transactionProcessingAccountName)
                .set(for: "type", value: builder.transactionType == .refund ? "REFUND" : "SALE")
                .set(for: "channel", value: self?.channel?.mapped(for: .gpApi))
                .set(for: "capture_mode", value: self?.captureMode(for: builder))
                //            .set(for: "remaining_capture_count", value: "") //Pending Russell
                .set(for: "authorization_mode", value: builder.allowPartialAuth ? "PARTIAL" : "WHOLE")
                .set(for: "amount", value: builder.amount?.toNumericCurrencyString())
                .set(for: "currency", value: builder.currency)
                .set(for: "reference", value: builder.clientTransactionId ?? UUID().uuidString)
                .set(for: "description", value: builder.requestDescription)
                .set(for: "order_reference", value: builder.orderId)
                //            .set(for: "initiator", value: "")// [PAYER, MERCHANT] //default to PAYER
                .set(for: "gratuity_amount", value: builder.gratuity?.toNumericCurrencyString())
                .set(for: "cashback_amount", value: builder.cashBackAmount?.toNumericCurrencyString())
                .set(for: "surcharge_amount", value: builder.surchargeAmount?.toNumericCurrencyString())
                .set(for: "convenience_amount", value: builder.convenienceAmount?.toNumericCurrencyString())
                .set(for: "country", value: builder.billingAddress?.country ?? self?.country)
                //            .set(for: "language", value: language?.mapped(for: .gpApi))
                .set(for: "ip_address", value: builder.customerIpAddress)
                //            .set(for: "site_reference", value: "")
                .set(for: "payment_method", doc: paymentMethod)

            self?.doTransaction(method: .post,
                                endpoint: Endpoints.transactions(),
                                data: data.toString(),
                                idempotencyKey: builder.idempotencyKey) { response, error in
                guard let response = response else {
                    completion?(nil, error)
                    return
                }
                let doc = JsonDoc.parse(response)
                let transaction = GpApiMapping.mapTransaction(doc)
                completion?(transaction, nil)
                return
            }
        }
    }

    private func entryMode(for builder: AuthorizationBuilder) -> String {
        if let card = builder.paymentMethod as? CardData {
            if card.readerPresent {
                return card.cardPresent ? "MANUAL" : "IN_APP"
            } else {
                return card.cardPresent ? "MANUAL" : "ECOM"
            }
        } else if let track = builder.paymentMethod as? TrackData {
            if builder.tagData != nil {
                return track.entryMethod == .swipe ? "CHIP" : "CONTACTLESS_CHIP"
            } else if builder.hasEmvFallbackData {
                return "CONTACTLESS_SWIPE"
            }
            return "SWIPE"
        }
        return "ECOM"
    }

    private func captureMode(for builder: AuthorizationBuilder) -> String {
        if builder.multiCapture {
            return "MULTIPLE"
        } else if builder.transactionType == .auth {
            return "LATER"
        }
        return "AUTO"
    }
}
