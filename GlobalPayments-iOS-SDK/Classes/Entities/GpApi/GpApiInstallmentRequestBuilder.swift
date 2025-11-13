import Foundation

struct GpApiInstallmentRequestBuilder<T> {
   
    typealias BuilderType = InstallmentBuilder
    func buildRequest(for builder: InstallmentBuilder<T>, config: GpApiConfig?) -> GpApiRequest? {
        let data: JsonDoc = PrepareInstallmentRequest(builder: builder, config: config)
        
        let request = GpApiRequest(
            endpoint: GpApiRequest.Endpoints.INSTALLMENT_ENDPOINT(),
            method: .post,
            requestBody: data.toString()
        )
        return request
    }
    
    private func PrepareInstallmentRequest(builder: InstallmentBuilder<T>, config: GpApiConfig?) -> JsonDoc {
        var installment = builder.entity as! Installment
        let requestData = JsonDoc()
            .set(for: "account_name", value: config?.accessTokenInfo?.transactionProcessingAccountName)
            .set(for: "amount", value: installment.Amount)
            .set(for: "channel", value: config?.channel.mapped(for: .gpApi))
            .set(for: "currency", value: installment.Currency)
            .set(for: "country", value: config?.country)
            .set(for: "reference", value: installment.Reference)
            .set(for: "program", value: installment.Program)
        
        let paymentMethodData = JsonDoc()
            .set(for: "entry_mode", value: installment.EntryMode)
        
        if let creditCardData = installment.CardDetails {
            let cardData =  JsonDoc()
                .set(for: "number", value: creditCardData.number)
                .set(for: "expiry_month", value: creditCardData.expMonth > .zero ? "\(creditCardData.expMonth)".leftPadding(toLength: 2, withPad: "0") : .empty)
                .set(for: "expiry_year", value: creditCardData.expYear > .zero ? "\(creditCardData.expYear)".leftPadding(toLength: 4, withPad: "0").substring(with: 2..<4) : .empty)
            paymentMethodData.set(for: "card", doc: cardData)
        }
        
        if let creditCardData = installment.encryption {
            let encryptionData =  JsonDoc()
                .set(for: "method", value: creditCardData.method)
                .set(for: "version", value: creditCardData.version)
                .set(for: "info", value: creditCardData.info)
                .set(for: "type", value: creditCardData.type)
            paymentMethodData.set(for: "encryption", doc: encryptionData)
        }
        
        requestData.set(for: "payment_method", doc: paymentMethodData)
            
        return requestData
    }
}
