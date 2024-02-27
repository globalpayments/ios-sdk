import Foundation

struct GpApiManagementRequestBuilder: GpApiRequestData {

    func generateRequest(for builder: ManagementBuilder, config: GpApiConfig) -> GpApiRequest? {
        var merchantUrl: String = !(config.merchantId?.isEmpty ?? true) ? "/merchants/\(config.merchantId ?? "")" : ""
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
                .set(for: "amount", value: builder.amount?.toNumericCurrencyString())
            return GpApiRequest(
                endpoint: merchantUrl + GpApiRequest.Endpoints.transactionsRefund(transactionId: (builder.transactionId ?? .empty)),
                method: .post,
                requestBody: payload.toString()
            )
        case .reversal:
            let payload = JsonDoc()
                .set(for: "amount", value: builder.amount?.toNumericCurrencyString())
                .set(for: "currency_conversion", value: builder.dccRateData?.dccId)
            
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
            let payload = JsonDoc()
                .set(for: "amount", value: builder.amount?.toNumericCurrencyString())
                .set(for: "gratuity", value: builder.gratuity?.toNumericCurrencyString())
                .set(for: "currency_conversion", value: builder.dccRateData?.dccId)
            return GpApiRequest(
                endpoint: merchantUrl + GpApiRequest.Endpoints.transactionsCapture(transactionId: builder.transactionId ?? .empty),
                method: .post,
                requestBody: payload.toString()
            )
        case .batchClose:
            return GpApiRequest(
                endpoint: merchantUrl + GpApiRequest.Endpoints.batchClose(id: builder.batchReference ?? .empty),
                method: .post
            )
        case .reauth:
            let payload = JsonDoc()
                .set(for: "amount", value: builder.amount?.toNumericCurrencyString())

            if builder.paymentMethod?.paymentMethodType == .ach {
                payload.set(for: "description", value: builder.description)
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
            payload.set(for: "amount", value: "\(builder.amount ?? 0)")

            if let lodgingData = builder.lodgingData, let items = lodgingData.items {

                let lodgingItems: [JsonDoc] = items.map {
                    let doc = JsonDoc()
                    doc.set(for: "Types", value: $0.types)
                    doc.set(for: "Reference", value: $0.reference)
                    doc.set(for: "TotalAmount", value: $0.totalAmount)
                    doc.set(for: "paymentMethodProgramCodes", value: $0.paymentMethodProgramCodes)
                    return doc
                }

                let lodgingDataDoc = JsonDoc()
                lodgingDataDoc.set(for: "booking_reference", value: lodgingData.bookingReference)
                lodgingDataDoc.set(for: "duration_days", value: "\(lodgingData.stayDuration ?? 0)")
                lodgingDataDoc.set(for: "date_checked_in", value: lodgingData.checkInDate?.format("yyyy-MM-dd"))
                lodgingDataDoc.set(for: "date_checked_out", value: lodgingData.checkOutDate?.format("yyyy-MM-dd"))
                lodgingDataDoc.set(for: "daily_rate_amount", value: "\(lodgingData.rate ?? 0 )")
                lodgingDataDoc.set(for: "charge_items", values: lodgingItems)
                payload.set(for: "lodging", doc: lodgingDataDoc)
            }

            return GpApiRequest(
                endpoint: GpApiRequest.Endpoints.transactionsIncrementalAuthorization(transactionId: (builder.transactionId ?? .empty)),
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
        case .edit:
            let card = JsonDoc()
            card.set(for: "tag", value: builder.tagData)

            let paymentMethod = JsonDoc()
            paymentMethod.set(for: "card", doc: card)

            let payload = JsonDoc()
            payload.set(for: "amount", value: builder.amount?.toNumericCurrencyString())
            payload.set(for: "gratuity_amount", value: builder.gratuity?.toNumericCurrencyString())
            payload.set(for: "payment_method", doc: paymentMethod)

            return GpApiRequest(
                endpoint: GpApiRequest.Endpoints.transactionsAdjusmentAuthorization(transactionId: (builder.transactionId ?? .empty)),
                method: .post,
                requestBody: payload.toString()
            )
        case .payLinkUpdate:
            
            let payLinkData = builder.payLinkData
            
            let payLoad = JsonDoc()
            
            payLoad.set(for: "usage_mode", value: payLinkData?.usageMode?.mapped(for: .gpApi))
            payLoad.set(for: "usage_limit", value: payLinkData?.usageLimit)
            payLoad.set(for: "name", value: payLinkData?.name)
            payLoad.set(for: "description", value: builder.description)
            payLoad.set(for: "type", value: payLinkData?.type?.mapped(for: .gpApi))
            payLoad.set(for: "status", value: payLinkData?.status?.mapped(for: .gpApi))
            payLoad.set(for: "shippable", value: payLinkData?.isShippable ?? false ? "YES" : "NO")
            payLoad.set(for: "shipping_amount", value:  payLinkData?.shippingAmount?.toNumericCurrencyString())

            let transaction = JsonDoc()
            transaction.set(for:"amount", value: builder.amount?.toNumericCurrencyString())

            payLoad.set(for:"transactions", doc: transaction)
            payLoad.set(for:"expiration_date", value: payLinkData?.expirationDate)
            payLoad.set(for:"images", value: payLinkData?.images)

            return GpApiRequest(
                endpoint: merchantUrl + GpApiRequest.Endpoints.payLinkWithId(id: builder.paymentLinkId ?? .empty),
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
            request.set(for: "amount", value: builder.amount?.toNumericCurrencyString())
            
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
}
