import Foundation

struct GpApiFileProcessingRequestBuilder<T> {
    
    func buildRequest(for builder: FileProcessingBuilder<T>, config: GpApiConfig?) -> GpApiRequest?{
        
        switch builder.fileProcessingActionType {
        case .CREATE_UPLOAD_URL:
            let payload = JsonDoc()
            payload.set(for: "merchant_id", value: config?.merchantId)
            payload.set(for: "account_id", value: config?.accessTokenInfo?.fileProcessingAccountID);
            
            let notifications = JsonDoc()
            notifications.set(for: "status_url", value: config?.statusUrl)
            
            if !notifications.keys.isEmpty {
                payload.set(for: "notifications", doc: notifications)
            }
            return GpApiRequest(
                endpoint: GpApiRequest.Endpoints.fileProcessing(),
                method: .post,
                requestBody: payload.toString()
            )
        case .GET_DETAILS:
            return GpApiRequest(
                endpoint: GpApiRequest.Endpoints.fileProcessing() + "/\(builder.resourceId ?? "")",
                method: .get
            )
        }
    }
}
