import Foundation

struct GpApiRecurringRequestBuilder<T> {
    
    func buildRequest(for builder: RecurringBuilder<T>, config: GpApiConfig?) -> GpApiRequest?{
        
        var merchantUrl = ""
        if let merchantId = config?.merchantId {
            merchantUrl = "/merchants/" + merchantId
        }
        
        switch builder.transactionType {
        case .create:
            let payload = preparePayerRequest(builder: builder)
            return GpApiRequest(
                endpoint: merchantUrl + GpApiRequest.Endpoints.payers(),
                method: .post,
                requestBody: payload.toString()
            )
        case .edit:
            let payload = preparePayerRequest(builder: builder)
            return GpApiRequest(
                endpoint: merchantUrl + GpApiRequest.Endpoints.editPayer(id: builder.entity?.id),
                method: .patch,
                requestBody: payload.toString()
            )
        default:
            break
        }
        return nil
    }
    
    private func preparePayerRequest(builder: RecurringBuilder<T>) -> JsonDoc {
        let customer = builder.entity as? Customer
        let data = JsonDoc()
        data.set(for: "first_name", value: customer?.firstName)
        data.set(for: "last_name", value: customer?.lastName)
        data.set(for: "reference", value: customer?.key)

        if let payments = customer?.paymentMethods, payments.count > 0 {
            let docs = payments.map {
                let doc = JsonDoc()
                doc.set(for: "id", value: $0.id)
                doc.set(for: "default", value: payments.first?.id == $0.id ? "YES" : "NO")
                return doc
            }
            data.set(for: "payment_methods", values: docs)
        }
        return data
    }
}
