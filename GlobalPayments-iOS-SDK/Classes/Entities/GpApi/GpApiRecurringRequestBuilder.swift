import Foundation

struct GpApiRecurringRequestBuilder<T> {
    
    func buildRequest(for builder: RecurringBuilder<T>, config: GpApiConfig?) -> GpApiRequest?{
        
        let merchantUrl = GpApiRequest.Endpoints.accountMerchantUrl(mmaId: config?.mmaId, merchantId: config?.merchantId)
        
        switch builder.transactionType {
        case .create:
            let payload = preparePayerRequest(builder: builder)
            return GpApiRequest(
                endpoint: merchantUrl + GpApiRequest.Endpoints.payers(),
                method: .post,
                requestBody: payload.toString()
            )
        case .edit:
            guard let id = builder.entity?.id, !id.isEmpty else { return nil }
            let payload = preparePayerRequest(builder: builder, isEdit: true)
            return GpApiRequest(
                endpoint: merchantUrl + GpApiRequest.Endpoints.editPayer(id: id),
                method: .patch,
                requestBody: payload.toString()
            )
        case .delete:
            guard let id = builder.entity?.id, !id.isEmpty else { return nil }
            return GpApiRequest(
                endpoint: merchantUrl + GpApiRequest.Endpoints.editPayer(id: id),
                method: .delete
            )
        case .fetch:
            guard let id = builder.entity?.id, !id.isEmpty else { return nil }
            var queryParams: [String: String]?
            if let masked = builder.masked {
                queryParams = ["masked": masked ? "YES" : "NO"]
            }
            return GpApiRequest(
                endpoint: merchantUrl + GpApiRequest.Endpoints.editPayer(id: id),
                method: .get,
                queryParams: queryParams
            )
        default:
            break
        }
        return nil
    }
    
    private func preparePayerRequest(builder: RecurringBuilder<T>, isEdit: Bool = false) -> JsonDoc {
        let customer = builder.entity as? Customer
        let data = JsonDoc()
        data.set(for: "first_name", value: customer?.firstName)
        data.set(for: "last_name", value: customer?.lastName)
        data.set(for: "reference", value: customer?.key)

        data.set(for: "email", value: customer?.email)
        data.set(for: "language", value: customer?.language)

        if isEdit, let payments = customer?.paymentMethods, payments.isEmpty {
            // Empty list removes every payment method from the payer.
            data.set(for: "payment_methods", values: [])
        } else if let payments = customer?.paymentMethods, payments.count > 0 {
            // Create: an explicitly flagged payment method wins; otherwise the first one is the default.
            // Edit: `default` is only sent for the payment method flagged as default.
            let defaultIndex = payments.firstIndex(where: { $0.preferredPayment == true }) ?? 0
            let docs = payments.enumerated().map { index, payment in
                let doc = JsonDoc()
                doc.set(for: "id", value: payment.id)
                if isEdit {
                    if payment.preferredPayment == true {
                        doc.set(for: "default", value: "YES")
                    }
                } else {
                    doc.set(for: "default", value: index == defaultIndex ? "YES" : "NO")
                }
                return doc
            }
            data.set(for: "payment_methods", values: docs)
        }
        return data
    }
}
