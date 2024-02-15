import Foundation

class RestGateway3ds: Gateway3ds {

    init() {
        super.init(session: .init(configuration: .default), contentType: "application/json")
    }

    func doRequest(method: HTTPMethod,
                       endpoint: String,
                       data: String? = nil,
                       queryStringParams: [String: String]? = nil,
                       completion: @escaping (String?, Error?) -> Void) {

        sendRequest(endpoint: endpoint,
                    method: method,
                    data: data,
                    queryStringParams: queryStringParams) { gatewayResponse, error in
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
            let error = parsed?.get(valueFor: "error") ?? parsed
            let message: String? = error?.getValue(key: "message")
            completion(nil, GatewayException(
                message: "Status Code: \(response.statusCode) - \(message ?? .empty)"
                )
            )
            return
        }
        completion(response.rawResponse, nil)
    }
}

