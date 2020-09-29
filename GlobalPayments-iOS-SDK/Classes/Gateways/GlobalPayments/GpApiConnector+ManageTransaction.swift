import Foundation

extension GpApiConnector {

    func manageTransaction(_ builder: ManagementBuilder,
                           completion: ((Transaction?, Error?) -> Void)?) {

        if builder.transactionType == .capture {
            let data = JsonDoc()
                .set(for: "amount", value: builder.amount?.toNumericCurrencyString())
                .set(for: "gratuity_amount", value: builder.gratuity?.toNumericCurrencyString())

            doTransaction(
                method: .post,
                endpoint: Endpoints.transactionsCapture(transactionId: builder.transactionId ?? .empty),
                data: data.toString()
            ) { [weak self] response, error in
                guard let response = response else {
                    completion?(nil, error)
                    return
                }
                let transaction = self?.mapResponse(response)
                completion?(transaction, nil)
            }
        } else if builder.transactionType == .refund {
            let data = JsonDoc()
                .set(for: "amount", value: builder.amount?.toNumericCurrencyString())

            doTransaction(
                method: .post,
                endpoint: Endpoints.transactionsRefund(transactionId: (builder.transactionId ?? .empty)),
                data: data.toString()
            ) { [weak self] response, error in
                guard let response = response else {
                    completion?(nil, error)
                    return
                }
                let transaction = self?.mapResponse(response)
                completion?(transaction, nil)
            }
        } else if builder.transactionType == .reversal {
            let data = JsonDoc()
                .set(for: "amount", value: builder.amount?.toNumericCurrencyString())

            doTransaction(
                method: .post,
                endpoint: Endpoints.transactionsReversal(transactionId: (builder.transactionId ?? .empty)),
                data: data.toString()
            ) { [weak self] response, error in
                guard let response = response else {
                    completion?(nil, error)
                    return
                }
                let transaction = self?.mapResponse(response)
                completion?(transaction, nil)
            }
        } else if let creditCardData = builder.paymentMethod as? CreditCardData, builder.transactionType == .tokenUpdate {

            let card = JsonDoc()
                .set(for: "expiry_month", value: creditCardData.expMonth > .zero ? "\(creditCardData.expMonth)".leftPadding(toLength: 2, withPad: "0") : .empty)
                .set(for: "expiry_year", value: creditCardData.expYear > .zero ? "\(creditCardData.expYear)".leftPadding(toLength: 4, withPad: "0").substring(with: 2..<4) : .empty)

            let payload = JsonDoc()
                .set(for: "card", doc: card)

            doTransaction(
                method: .patch,
                endpoint: Endpoints.paymentMethodsEdit(token: ((builder.paymentMethod as? Tokenizable)?.token ?? .empty)),
                data: payload.toString()
            ) { [weak self] response, error in
                guard let response = response else {
                    completion?(nil, error)
                    return
                }
                let transaction = self?.mapResponse(response)
                completion?(transaction, nil)
            }
        } else if let tokenizable = builder.paymentMethod as? Tokenizable,
                  builder.transactionType == .tokenDelete {

            doTransaction(
                method: .post,
                endpoint: Endpoints.paymentMethodsDelete(token: (tokenizable.token ?? .empty))
            ) { [weak self] response, error in
                guard let response = response else {
                    completion?(nil, error)
                    return
                }
                let transaction = self?.mapResponse(response)
                completion?(transaction, nil)
            }
        } else if let detokenizable = builder.paymentMethod as? Tokenizable,
                  builder.transactionType == .detokenize {

            doTransaction(
                method: .post,
                endpoint: Endpoints.paymentMethodsDetokenize(token: (detokenizable.token ?? .empty))
            ) { [weak self] response, error in
                guard let response = response else {
                    completion?(nil, error)
                    return
                }
                let transaction = self?.mapResponse(response)
                completion?(transaction, nil)
            }
        }
    }
}
