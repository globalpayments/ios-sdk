import Foundation

struct ApiRequest {
    var endpoint: String
    var method: HTTPMethod
    var requestBody: String?
    var queryParams: [String: String]?

    init(endpoint: String,
         method: HTTPMethod,
         requestBody: String? = nil,
         queryParams: [String: String]? = nil) {

        self.endpoint = endpoint
        self.method = method
        self.requestBody = requestBody
        self.queryParams = queryParams
    }
}

extension ApiRequest {

    struct Endpoints {
        
        static func accessToken() -> String {
            "/accessToken"
        }
        
        static func checkEnrollment() -> String {
            "/checkEnrollment"
        }
        
        static func sendAuthenticationParams() -> String {
            "/initiateAuthentication"
        }
        
        static func getAuthenticationData() -> String {
            "/getAuthenticationData"
        }
        
        static func authorizationData() -> String {
            "/authorizationData"
        }
    }
}
