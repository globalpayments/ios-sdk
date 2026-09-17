import Foundation

struct GpApiManagementRequestBuilder: GpApiRequestData {

    private func dccCurrencyConversionDoc(for builder: ManagementBuilder) -> JsonDoc? {
        guard let dccId = builder.dccRateData?.dccId, !dccId.isEmpty else { return nil }

        let requestType = builder.dccRateData?.dccRateType ?? builder.dccRateData?.normalizedRateType() ?? .sale
        let requestTypeValue = requestType == .sale ? "SALE" : "REFUND"

        let currencyConversion = JsonDoc()
            .set(for: "id", value: dccId)
            .set(for: "request_type", value: requestTypeValue)
            .set(for: "type", value: requestTypeValue)
            .set(for: "transaction_type", value: requestTypeValue)
        return currencyConversion
    }

    func generateRequest(for builder: ManagementBuilder, config: GpApiConfig) -> GpApiRequest? {
        var merchantUrl: String = !(config.merchantId?.isEmpty ?? true) ? "/merchants/\(config.merchantId ?? "")" : ""

        // Resolve the currency for amount encoding.
        // Management calls (Capture, Reverse, Refund) typically omit .withCurrency()
        // and rely on the original authorization's currency, which is carried on the
        // TransactionReference produced by the gateway response mapper.
        let amountCurrency = builder.currency ?? (builder.paymentMethod as? TransactionReference)?.currency

        switch builder.transactionType {
        case .tokenDelete:
            let token = getToken(from: builder)
            return GpApiRequest(
                endpoint: merchantUrl + GpApiRequest.Endpoints.paymentMethodsWith(token: token),
                method: .delete
            )
        case .tokenUpdate:
            let token = getToken(from: builder)
            let payload = JsonDoc()
            if let creditCardData = builder.paymentMethod as? CreditCardData {
                let card = JsonDoc()
                    .set(for: "number", value: creditCardData.number)
                    .set(for: "expiry_month", value: creditCardData.expMonth > .zero ? "\(creditCardData.expMonth)".leftPadding(toLength: 2, withPad: "0") : .empty)
                    .set(for: "expiry_year", value: creditCardData.expYear > .zero ? "\(creditCardData.expYear)".leftPadding(toLength: 4, withPad: "0").substring(with: 2..<4) : .empty)
                    .set(for: "name", value: creditCardData.cardHolderName)

                if let methodUsage = creditCardData.methodUsageMode?.rawValue {
                    payload.set(for: "usage_mode", value: methodUsage)
                }

                payload.set(for: "card", doc: card)
            }
            return GpApiRequest(
                endpoint: merchantUrl + GpApiRequest.Endpoints.paymentMethodsWith(token: token),
                method: .patch,
                requestBody: payload.toString()
            )
        case .refund:
            let payload = JsonDoc()
                .set(for: "amount", value: builder.amount?.toNumericCurrencyString(currency: amountCurrency))
                .set(for: "gratuity_amount", value: builder.gratuity?.toNumericCurrencyString(currency: amountCurrency))
                .set(for: "tax_amount", value: builder.taxAmount?.toNumericCurrencyString(currency: amountCurrency))
                .set(for: "reference", value: builder.reference)
                .set(for: "surcharge_amount", value: builder.surchargeAmtInfo)

            if let currencyConversion = dccCurrencyConversionDoc(for: builder) {
                payload.set(for: "currency_conversion", doc: currencyConversion)
            }

            // Build order object if any order fields are present
            let hasOrderFields = builder.shippingAmount != nil || builder.dutyAmount != nil || !(builder.orderTaxes?.isEmpty ?? true)
            if hasOrderFields {
                let orderDoc = JsonDoc()
                orderDoc.set(for: "shipping_amount", value: builder.shippingAmount?.toNumericCurrencyString(currency: amountCurrency))
                orderDoc.set(for: "duty_amount", value: builder.dutyAmount?.toNumericCurrencyString(currency: amountCurrency))
                if let taxes = builder.orderTaxes, !taxes.isEmpty {
                    let taxDocs: [JsonDoc] = taxes.map {
                        let t = JsonDoc()
                        t.set(for: "type", value: $0.type)
                        t.set(for: "amount", value: $0.amount)
                        t.set(for: "percentage", value: $0.percentage)
                        return t
                    }
                    orderDoc.set(for: "taxes", values: taxDocs)
                }
                payload.set(for: "order", doc: orderDoc)
            }

            return GpApiRequest(
                endpoint: merchantUrl + GpApiRequest.Endpoints.transactionsRefund(transactionId: (builder.transactionId ?? .empty)),
                method: .post,
                requestBody: payload.toString()
            )
        case .reversal:
            let currencyConversionDoc = dccCurrencyConversionDoc(for: builder)
            let payload = JsonDoc()
                .set(for: "amount", value: builder.amount?.toNumericCurrencyString(currency: amountCurrency))
                .set(for: "reversal_reason", value: builder.reversalReason?.mapped(for: .gpApi))
                .set(for: "currency_conversion", doc: currencyConversionDoc)
            
            var endpoint = merchantUrl
            
            if (builder.paymentMethod?.paymentMethodType == .accountFunds) {
                if builder.fundsData?.merchantId?.isEmpty ?? true {
                    endpoint = GpApiRequest.Endpoints.merchantWithID(config.merchantId ?? .empty)
                }
                endpoint += GpApiRequest.Endpoints.transfersReversal(transferId: (builder.transactionId ?? .empty))
            } else {
                endpoint += GpApiRequest.Endpoints.transactionsReversal(transactionId: (builder.transactionId ?? .empty))
            }
            
            return GpApiRequest(
                endpoint: endpoint,
                method: .post,
                requestBody: payload.toString()
            )
        case .capture:
            let captureCurrencyConversionDoc = dccCurrencyConversionDoc(for: builder)
            let captureSequence: String? = {
                guard let sequence = builder.multiCaptureSequence,
                      let total = builder.multiCapturePaymentCount else { return nil }
                if sequence == 1 { return "FIRST" }
                if sequence == total { return "LAST" }
                return "SUBSEQUENT"
            }()
            let payload = JsonDoc()
                .set(for: "amount", value: builder.amount?.toNumericCurrencyString(currency: amountCurrency))
                .set(for: "gratuity_amount", value: builder.gratuity?.toNumericCurrencyString(currency: amountCurrency))
                .set(for: "tax_amount", value: builder.taxAmount?.toNumericCurrencyString(currency: amountCurrency))
                .set(for: "tag", value: builder.tagData)
                .set(for: "capture_sequence", value: captureSequence)
                .set(for: "total_capture_count", value: builder.multiCapturePaymentCount.map { "\($0)" })
                .set(for: "currency_conversion", doc: captureCurrencyConversionDoc)

            if let lodgingData = builder.lodgingData, let items = lodgingData.items {
                let lodgingItems: [JsonDoc] = items.map {
                    let doc = JsonDoc()
                    doc.set(for: "types", value: $0.types.map { [$0] })
                    doc.set(for: "amount", value: $0.totalAmount)
                    doc.set(for: "payment_method_program_codes", value: $0.paymentMethodProgramCodes)
                    return doc
                }
                let lodgingDoc = JsonDoc()
                    .set(for: "booking_reference", value: lodgingData.bookingReference)
                    .set(for: "duration_days", value: lodgingData.stayDuration.map { "\($0)" })
                    .set(for: "date_checked_in", value: lodgingData.checkInDate?.format("yyyy-MM-dd"))
                    .set(for: "date_checked_out", value: lodgingData.checkOutDate?.format("yyyy-MM-dd"))
                    .set(for: "daily_rate_amount", value: lodgingData.rate.map { "\($0)" })
                lodgingDoc.set(for: "charge_items", values: lodgingItems)
                payload.set(for: "lodging", doc: lodgingDoc)
            }

            return GpApiRequest(
                endpoint: merchantUrl + GpApiRequest.Endpoints.transactionsCapture(transactionId: builder.transactionId ?? .empty),
                method: .post,
                requestBody: payload.toString()
            )
        case .batchClose:
            // Route to POST /batches/{id} when a batch reference is available (existing flow).
            // Route to POST /batches with account-based body when no batch reference is set (new flow).
            if hasText(builder.batchReference) {
                return GpApiRequest(
                    endpoint: merchantUrl + GpApiRequest.Endpoints.batchClose(id: builder.batchReference ?? .empty),
                    method: .post
                )
            }

            let payload = JsonDoc()
                .set(for: "account_name", value: builder.accountName)
                .set(for: "account_id", value: builder.accountId)
                .set(for: "channel", value: builder.channel?.mapped(for: .gpApi))
                .set(for: "currency", value: builder.currency)
                .set(for: "country", value: builder.country)
                .set(for: "payment_methods", value: builder.paymentMethods?.compactMap { $0.mapped(for: .gpApi) })

            return GpApiRequest(
                endpoint: merchantUrl + GpApiRequest.Endpoints.batches(),
                method: .post,
                requestBody: payload.toString()
            )
        case .reauth:
            let reauthCurrencyConversionDoc = dccCurrencyConversionDoc(for: builder)
            let transactionRequestType = (builder.dccRateData?.dccRateType ?? builder.dccRateData?.normalizedRateType() ?? .sale) == .refund ? "REFUND" : "SALE"
            let payload = JsonDoc()
                .set(for: "type", value: transactionRequestType)
                .set(for: "amount", value: builder.amount?.toNumericCurrencyString(currency: amountCurrency))
                .set(for: "gratuity_amount", value: builder.gratuity?.toNumericCurrencyString(currency: amountCurrency))
                .set(for: "tax_amount", value: builder.taxAmount?.toNumericCurrencyString(currency: amountCurrency))
                .set(for: "currency_conversion", doc: reauthCurrencyConversionDoc)

            if builder.paymentMethod?.paymentMethodType == .ach {
                payload.set(for: "description", value: builder.managementBuilderDescription)
                if let eCheck = builder.paymentMethod as? eCheck {

                    let paymentMethod = JsonDoc()
                    paymentMethod.set(for: "narrative", value: eCheck.merchantNotes)

                    let bankTransfer = JsonDoc()
                    bankTransfer.set(for: "account_number", value: eCheck.accountNumber)
                    bankTransfer.set(for: "account_type", value: eCheck.accountType?.rawValue)
                    bankTransfer.set(for: "check_reference", value: eCheck.checkReference)

                    let bank = JsonDoc()
                    bank.set(for: "code", value: eCheck.routingNumber)
                    bank.set(for: "name", value: eCheck.bankName)

                    bankTransfer.set(for: "bank", doc: bank)
                    paymentMethod.set(for: "bank_transfer", doc: bankTransfer)
                    payload.set(for: "payment_method", doc: paymentMethod)
                }
            }

            return GpApiRequest(
                endpoint: merchantUrl + GpApiRequest.Endpoints.transactionsReauthorization(transactionId: (builder.transactionId ?? .empty)),
                method: .post,
                requestBody: payload.toString()
            )
        case .auth:
            let payload = JsonDoc()
                .set(for: "amount", value: builder.amount?.toNumericCurrencyString(currency: amountCurrency))
                .set(for: "tax_amount", value: builder.taxAmount?.toNumericCurrencyString(currency: amountCurrency))

            if let tag = builder.tagData, !tag.isEmpty {
                let card = JsonDoc().set(for: "tag", value: tag)

                let paymentMethod = JsonDoc().set(for: "card", doc: card)
                payload.set(for: "payment_method", doc: paymentMethod)
            }

            if let taxes = builder.orderTaxes, !taxes.isEmpty {
                let totalTaxAmount = taxes.reduce(NSDecimalNumber.zero) { currentTotal, tax in
                    currentTotal.adding(NSDecimalNumber(string: tax.amount))
                }
                if payload.getValue(key: "tax_amount") == nil {
                    payload.set(for: "tax_amount", value: totalTaxAmount.toNumericCurrencyString(currency: amountCurrency))
                }
            }

            if let lodgingData = builder.lodgingData, let items = lodgingData.items {
                let lodgingItems: [JsonDoc] = items.map {
                    let doc = JsonDoc()
                    doc.set(for: "types", value: $0.types.map { [$0] })
                    doc.set(for: "amount", value: $0.totalAmount)
                    doc.set(for: "payment_method_program_codes", value: $0.paymentMethodProgramCodes)
                    return doc
                }
                let lodgingDoc = JsonDoc()
                    .set(for: "booking_reference", value: lodgingData.bookingReference)
                    .set(for: "duration_days", value: lodgingData.stayDuration.map { "\($0)" })
                    .set(for: "room_tax_amount", value: lodgingData.roomTaxAmount.map { "\($0)" })
                    .set(for: "date_checked_in", value: lodgingData.checkInDate?.format("yyyy-MM-dd"))
                    .set(for: "date_checked_out", value: lodgingData.checkOutDate?.format("yyyy-MM-dd"))
                    .set(for: "daily_rate_amount", value: lodgingData.rate.map { "\($0)" })
                    .set(for: "establishment_name", value: lodgingData.establishmentName)
                    .set(for: "time_checked_in", value: lodgingData.checkInTime)
                    .set(for: "time_checked_out", value: lodgingData.checkOutTime)
                lodgingDoc.set(for: "charge_items", values: lodgingItems)
                payload.set(for: "lodging", doc: lodgingDoc)
            }

            return GpApiRequest(
                endpoint: merchantUrl + GpApiRequest.Endpoints.transactionsIncrementalAuthorization(transactionId: (builder.transactionId ?? .empty)),
                method: .post,
                requestBody: payload.toString()
            )
        case .release, .hold:
            let payload = JsonDoc()
                .set(for: "reason_code", value: builder.reasonCode?.rawValue)

            let endpoint = builder.transactionType == .release ? "release" : builder.transactionType == .hold ? "hold" : ""

            return GpApiRequest(
                endpoint: merchantUrl + GpApiRequest.Endpoints.transactionsReleaseHold(transactionId: (builder.transactionId ?? .empty), endpoint: endpoint),
                method: .post,
                requestBody: payload.toString()
            )
        case .detokenize:
            let token = getToken(from: builder)
            return GpApiRequest(
                endpoint: merchantUrl + GpApiRequest.Endpoints.paymentMethodsDetokenize(id: token),
                method: .post
            )
        case .generateCryptogram:
            let payload = JsonDoc()
            if let amount = builder.amount {
                let transaction = JsonDoc()
                transaction.set(for: "amount", value: amount.toNumericCurrencyString(currency: builder.currency))
                payload.set(for: "transaction", doc: transaction)
            }
            // If a stored PMT_ token is present, use POST /payment-methods/{id}/cryptogram
            if let tokenizable = builder.paymentMethod as? Tokenizable,
               let pmtToken = tokenizable.token, pmtToken.starts(with: "PMT_") {
                return GpApiRequest(
                    endpoint: merchantUrl + GpApiRequest.Endpoints.paymentMethodsCryptogramFromStored(id: pmtToken),
                    method: .post,
                    requestBody: payload.toString()
                )
            }
            // Otherwise use POST /payment-methods/cryptogram with card.network_token
            if let creditCard = builder.paymentMethod as? Credit, let networkToken = creditCard.networkToken {
                let card = JsonDoc()
                card.set(for: "network_token", value: networkToken)
                payload.set(for: "card", doc: card)
            }
            return GpApiRequest(
                endpoint: merchantUrl + GpApiRequest.Endpoints.paymentMethodsCryptogram(),
                method: .post,
                requestBody: payload.toString()
            )
        case .edit:
            // If the payment method is a stored token (PMT_), route to PATCH /payment-methods/{id}
            if let tokenizable = builder.paymentMethod as? Tokenizable,
               let token = tokenizable.token, token.starts(with: "PMT_") {
                let payload = JsonDoc()
                payload.set(for: "name", value: builder.paymentMethodName)

                // Only include card block when expiry was explicitly provided (non-zero values)
                if let cardData = builder.paymentMethod as? CreditCardData {
                    let expiryMonth = cardData.expMonth > .zero ? "\(cardData.expMonth)".leftPadding(toLength: 2, withPad: "0") : nil
                    let expiryYear = cardData.expYear > .zero ? "\(cardData.expYear)".leftPadding(toLength: 4, withPad: "0").substring(with: 2..<4) : nil
                    if let month = expiryMonth, let year = expiryYear {
                        let card = JsonDoc()
                        card.set(for: "expiry_month", value: month)
                        card.set(for: "expiry_year", value: year)
                        payload.set(for: "card", doc: card)
                    }
                }

                return GpApiRequest(
                    endpoint: merchantUrl + GpApiRequest.Endpoints.paymentMethodsWith(paymentMethodId: token),
                    method: .patch,
                    requestBody: payload.toString()
                )
            }

            let card = JsonDoc()
            card.set(for: "tag", value: builder.tagData)

            let paymentMethod = JsonDoc()
            paymentMethod.set(for: "card", doc: card)

            let payload = JsonDoc()
            payload.set(for: "amount", value: builder.amount?.toNumericCurrencyString(currency: amountCurrency))
            payload.set(for: "gratuity_amount", value: builder.gratuity?.toNumericCurrencyString(currency: amountCurrency))
            payload.set(for: "surcharge_amount", value: builder.surchargeAmtInfo)
            payload.set(for: "tax_amount", value: builder.taxAmount?.toNumericCurrencyString(currency: amountCurrency))
            payload.set(for: "payment_method", doc: paymentMethod)

            return GpApiRequest(
                endpoint: GpApiRequest.Endpoints.transactionsAdjusmentAuthorization(transactionId: (builder.transactionId ?? .empty)),
                method: .post,
                requestBody: payload.toString()
            )
        case .payByLinkUpdate:
            
            let payByLinkData = builder.payByLinkData
            
            let payLoad = JsonDoc()
            
            payLoad.set(for: "usage_mode", value: payByLinkData?.usageMode?.mapped(for: .gpApi))
            payLoad.set(for: "usage_limit", value: payByLinkData?.usageLimit)
            payLoad.set(for: "name", value: payByLinkData?.name)
            payLoad.set(for: "description", value: builder.description)
            payLoad.set(for: "type", value: payByLinkData?.type?.mapped(for: .gpApi))
            payLoad.set(for: "status", value: payByLinkData?.status?.mapped(for: .gpApi))
            payLoad.set(for: "shippable", value: payByLinkData?.isShippable ?? false ? "YES" : "NO")
            payLoad.set(for: "shipping_amount", value:  payByLinkData?.shippingAmount?.toNumericCurrencyString(currency: builder.currency))

            let transaction = JsonDoc()
            transaction.set(for:"amount", value: builder.amount?.toNumericCurrencyString(currency: builder.currency))

            payLoad.set(for:"transactions", doc: transaction)
            payLoad.set(for:"expiration_date", value: payByLinkData?.expirationDate)
            payLoad.set(for:"images", value: payByLinkData?.images)

            return GpApiRequest(
                endpoint: merchantUrl + GpApiRequest.Endpoints.payByLinkWithId(id: builder.paymentLinkId ?? .empty),
                method: .patch,
                requestBody: payLoad.toString()
            )
            
        case .confirm:
            if let transactionReference = builder.paymentMethod as? TransactionReference, builder.paymentMethod?.paymentMethodType == .apm {
                let apmResponse = transactionReference.alternativePaymentResponse
                let apm = JsonDoc()
                apm.set(for: "provider", value: apmResponse?.providerName)
                apm.set(for: "provider_payer_reference", value: apmResponse?.providerReference);

                let paymentMethod = JsonDoc()
                paymentMethod.set(for: "apm", doc: apm)

                let payLoad = JsonDoc()
                payLoad.set(for: "payment_method", doc: paymentMethod)
                
                return GpApiRequest(
                    endpoint: merchantUrl + GpApiRequest.Endpoints.transactionsConfirmation(transactionId: builder.transactionId ?? .empty),
                    method: .post,
                    requestBody: payLoad.toString()
                )
            }
            return nil
        case .splitFunds:
            let payLoad = JsonDoc()
            var split = [JsonDoc]()

            let request = JsonDoc()
            request.set(for: "recipient_account_id", value: builder.fundsData?.recipientAccountId)
            request.set(for: "reference", value: builder.reference)
            request.set(for: "description", value: builder.managementBuilderDescription)
            request.set(for: "amount", value: builder.amount?.toNumericCurrencyString(currency: builder.currency))
            
            if let merchantId = builder.fundsData?.merchantId, !merchantId.isEmpty {
                merchantUrl = GpApiRequest.Endpoints.merchantWithID(merchantId)
            }
            
            split.append(request)
            payLoad.set(for: "transfers", values: split)
            
            return GpApiRequest(
                endpoint: merchantUrl + GpApiRequest.Endpoints.transactionsSplit(transactionId: builder.transactionId ?? .empty),
                method: .post,
                requestBody: payLoad.toString()
            )
        case .challenge:
            let payLoad = JsonDoc()
            if let documents = builder.disputeDocuments, !documents.isEmpty {
                var documentDocs = [JsonDoc]()
                for document in documents {
                    let documentDoc = JsonDoc()
                    if let b64 = document.b64Content {
                        documentDoc.set(for: "b64_content", value: b64.base64EncodedString())
                    }
                    documentDoc.set(for: "file_format", value: document.fileFormat)
                    documentDocs.append(documentDoc)
                }
                payLoad.set(for: "documents", values: documentDocs)
            }
            return GpApiRequest(
                endpoint: merchantUrl + GpApiRequest.Endpoints.transactionsChallenge(transactionId: builder.transactionId ?? .empty),
                method: .post,
                requestBody: payLoad.toString()
            )
        default:
            return nil
        }
    }

    private func getToken(from builder: ManagementBuilder) -> String {
        guard let tokenizable = builder.paymentMethod as? Tokenizable,
              let token = tokenizable.token, !token.isEmpty else {
                  return .empty
              }
        return token
    }

    private func hasText(_ value: String?) -> Bool {
        guard let value = value else {
            return false
        }
        return !value.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
}
