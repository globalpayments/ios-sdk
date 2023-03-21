import Foundation

class ApiSessionInfo {
    
    static func checkEnrollment(_ cardToken: String, amount: Decimal, currency: String, decoupledAuth: Bool) -> ApiRequest {
        let request = JsonDoc()
            .set(for: "cardToken", value: cardToken)
            .set(for: "amount", value: amount)
            .set(for: "currency", value: currency)
            .set(for: "preferredDecoupledAuth", value: decoupledAuth)

        return ApiRequest(
            endpoint: ApiRequest.Endpoints.checkEnrollment(),
            method: .post,
            requestBody: request.toString()
        )
    }
    
    static func sendAuthenticationParams(_ cardToken: String, amount: Decimal, currency: String, mobileData: MobileData, threeDSecure: ThreeDSecureRequest, decoupledAuth: Bool, decoupledTimeout: Int) -> ApiRequest{
        let request = JsonDoc()
            .set(for: "cardToken", value: cardToken)
            .set(for: "amount", value: "\(amount)")
            .set(for: "currency", value: currency)
            .set(for: "customerEmail", value: "abc@def.com")
            .set(for: "mobileData", doc: mapMobileData(mobileData))
            .set(for: "threeDsecure", doc: threeDSecure.toJson())
            .set(for: "preferredDecoupledAuth", value: decoupledAuth)
            .set(for: "decoupledFlowTimeout", value: decoupledTimeout)
        
        return ApiRequest(
            endpoint: ApiRequest.Endpoints.sendAuthenticationParams(),
            method: .post,
            requestBody: request.toString()
        )
    }
    
    static func generateAccessToken(_ appId: String, apiKey: String) -> ApiRequest{
        let request = JsonDoc()
            .set(for: "appId", value: appId)
            .set(for: "appKey", value: apiKey)
            .set(for: "permissions", value: [String]())
        
        return ApiRequest(
            endpoint: ApiRequest.Endpoints.accessToken(),
            method: .post,
            requestBody: request.toString()
        )
    }
    
    static func getAuthData(_ serverTransactionId: String) -> ApiRequest{
        let request = JsonDoc()
            .set(for: "serverTransactionId", value: serverTransactionId)
        
        return ApiRequest(
            endpoint: ApiRequest.Endpoints.getAuthenticationData(),
            method: .post,
            requestBody: request.toString()
        )
    }
    
    static func authorizationData(_ cardToken: String, amount: Decimal, currency: String, serverTransactionId: String) -> ApiRequest{
        let request = JsonDoc()
            .set(for: "cardToken", value: cardToken)
            .set(for: "amount", value: amount)
            .set(for: "currency", value: currency)
            .set(for: "serverTransactionId", value: serverTransactionId)
        
        return ApiRequest(
            endpoint: ApiRequest.Endpoints.authorizationData(),
            method: .post,
            requestBody: request.toString()
        )
    }
    
    static func mapMobileData(_ mobileData: MobileData?) -> JsonDoc {
        return JsonDoc().set(for: "applicationReference", value: mobileData?.applicationReference)
            .set(for: "ephemeralPublicKeyX", value: mobileData?.ephemeralPublicKey?.getValue(key: "x") as String?)
            .set(for: "ephemeralPublicKeyY", value: mobileData?.ephemeralPublicKey?.getValue(key: "y") as String?)
            .set(for: "sdkInterface", value: mobileData?.sdkInterface?.rawValue.uppercased())
            .set(for: "sdkUiTypes", value: mobileData?.sdkUiTypes?.map({ type in
                type.rawValue.uppercased()
            }))
            .set(for: "maximumTimeout", value: mobileData?.maximumTimeout ?? 10)
            .set(for: "referenceNumber", value: mobileData?.referenceNumber)
            .set(for: "sdkTransReference", value: mobileData?.sdkTransReference)
            .set(for: "encodedData", value: mobileData?.encodedData)
    }
}
