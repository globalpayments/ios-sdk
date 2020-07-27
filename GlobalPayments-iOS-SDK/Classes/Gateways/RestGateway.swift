import Foundation

class RestGateway: Gateway {

    init() {
        super.init(contentType: "application/json")
    }

    func doTransaction(method: HTTPMethod,
                       endpoint: String,
                       data: String? = nil,
                       queryStringParams: [String: String]? = nil,
                       completion: @escaping (String?, Error?) -> Void) {

        sendRequest(endpoint: endpoint,
                    method: method,
                    data: data,
                    queryStringParams: queryStringParams) { [weak self] gatewayResponse, error in
                        self?.handleResponse(
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
            let error = parsed?.get(valueFor: "error") ?? parsed
            completion(nil, GatewayException.generic(
                responseCode: response.statusCode,
                responseMessage: error?.getValue(key: "message")
                )
            )
            return
        }
        completion(response.rawResponse, nil)
    }
}
