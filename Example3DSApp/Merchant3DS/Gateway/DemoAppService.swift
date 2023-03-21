import Foundation

class DemoAppService {
    
    static func checkEnrollment(cardToken: String, amount: Decimal, currency: String, decoupledAuth: Bool, completion: @escaping (CheckEnrollmentResponse?, Error?) -> Void){
        
        let request = ApiSessionInfo.checkEnrollment(cardToken, amount: amount, currency: currency, decoupledAuth: decoupledAuth)
        doRequest(request: request) { data, error in
            completion(CheckEnrollmentResponse().mapFromSource(data), error)
        }
    }
    
    static func generateToken(completion: @escaping (AccessTokenResponse?, Error?) -> Void) {
        let request = ApiSessionInfo.generateAccessToken(ApiConstants.appId, apiKey: ApiConstants.apiKey)
        doRequest(request: request){ data, error in
            completion(AccessTokenResponse().mapFromSource(data), error)
        }
    }
    
    static func sendAuthenticationParams(_ cardToken: String, amount: Decimal, currency: String, mobileData: MobileData,threeDSecure: ThreeDSecureRequest, decoupledAuth: Bool, decoupledTimeout: Int, completion: @escaping (AuthParamsResponse?, Error?) -> Void){
        let request = ApiSessionInfo.sendAuthenticationParams(cardToken, amount: amount, currency: currency, mobileData: mobileData, threeDSecure: threeDSecure, decoupledAuth: decoupledAuth, decoupledTimeout: decoupledTimeout)
        doRequest(request: request){ data, error in
            completion(AuthParamsResponse().mapFromSource(data), error)
        }
    }
    
    static func getAuthData(_ serverTransactionId: String, completion: @escaping (AuthDataResponse?, Error?) -> Void){
        let request = ApiSessionInfo.getAuthData(serverTransactionId)
        doRequest(request: request){ data, error in
            completion(AuthDataResponse().mapFromSource(data), error)
        }
    }
    
    static func authorizationData(_ cardToken: String, amount: Decimal, currency: String, serverTransactionId: String, completion: @escaping (TransactionResponse?, Error?) -> Void ){
        let request = ApiSessionInfo.authorizationData(cardToken, amount: amount, currency: currency, serverTransactionId: serverTransactionId)
        doRequest(request: request){ data, error in
            completion(TransactionResponse().mapFromSource(data), error)
        }
    }
    
    private static func doRequest(request: ApiRequest, completion: @escaping (String?, Error?) -> Void){
        ServicesContainer.shared.client().doRequestData(method: request.method, endpoint: request.endpoint, data: request.requestBody, queryStringParams: request.queryParams, completion: completion)
    }
}
