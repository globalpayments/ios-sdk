import Foundation

struct GpApiManagementRequestBuilder: GpApiRequestData {

    func generateRequest(for builder: ManagementBuilder, config: GpApiConfig) -> GpApiRequest? {

        switch builder.transactionType {
        case .detokenize:
            let token = getToken(from: builder)
            return GpApiRequest(
                endpoint: GpApiRequest.Endpoints.paymentMethodsDetokenize(token: token),
                method: .post
            )
        case .tokenDelete:
            let token = getToken(from: builder)
            return GpApiRequest(
                endpoint: GpApiRequest.Endpoints.paymentMethodsWith(token: token),
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
                payload.set(for: "card", doc: card)
            }
            return GpApiRequest(
                endpoint: GpApiRequest.Endpoints.paymentMethodsWith(token: token),
                method: .patch,
                requestBody: payload.toString()
            )
        case .refund:
            let payload = JsonDoc()
                .set(for: "amount", value: builder.amount?.toNumericCurrencyString())
            return GpApiRequest(
                endpoint: GpApiRequest.Endpoints.transactionsRefund(transactionId: (builder.transactionId ?? .empty)),
                method: .post,
                requestBody: payload.toString()
            )
        case .reversal:
            let payload = JsonDoc()
                .set(for: "amount", value: builder.amount?.toNumericCurrencyString())
            return GpApiRequest(
                endpoint: GpApiRequest.Endpoints.transactionsReversal(transactionId: (builder.transactionId ?? .empty)),
                method: .post,
                requestBody: payload.toString()
            )
        case .capture:
            let payload = JsonDoc()
                .set(for: "amount", value: builder.amount?.toNumericCurrencyString())
                .set(for: "gratuity", value: builder.gratuity?.toNumericCurrencyString())
            return GpApiRequest(
                endpoint: GpApiRequest.Endpoints.transactionsCapture(transactionId: builder.transactionId ?? .empty),
                method: .post,
                requestBody: payload.toString()
            )
        case .batchClose:
            return GpApiRequest(
                endpoint: GpApiRequest.Endpoints.batchClose(id: builder.batchReference ?? .empty),
                method: .post
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
