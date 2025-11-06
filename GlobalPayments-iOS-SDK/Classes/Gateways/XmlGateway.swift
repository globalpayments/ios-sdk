import Foundation

class XmlGateway: Gateway {
    
    init() {
        super.init(contentType: "text/xml")
    }
    
    func doTransaction(endpoint: String,
                       method: HTTPMethod,
                       request: String? = nil,
                       completion: @escaping (String?, Error?) -> Void) {
        
        sendRequest(endpoint: endpoint,
                    method: method,
                    data: request) { gatewayResponse, error in
            self.handleResponse(
                response: gatewayResponse,
                error: error,
                completion: completion
            )
        }
    }
    
    func handleResponse(response: GatewayResponse?,
                        error: Error?,
                        completion: @escaping (String?, Error?) -> Void) {
        guard let response = response else {
            completion(nil, error)
            return
        }
        if response.statusCode != 200 && response.statusCode != 204 {
            let parsed = JsonDoc.parse(response.rawResponse)
            let errorCode: String = parsed?.getValue(key: "error_code") ?? .empty
            let detailedErrorCode: String = parsed?.getValue(key: "detailed_error_code") ?? .empty
            let detailedErrorDescription: String = parsed?.getValue(key: "detailed_error_description") ?? .empty
            let exception = GatewayException(
                message: "Status Code: \(response.statusCode) - \(String(describing: detailedErrorDescription))",
                responseCode: errorCode,
                responseMessage: detailedErrorCode
            )
            completion(nil, exception)
            return
        }
        completion(response.rawResponse, nil)
    }
}
