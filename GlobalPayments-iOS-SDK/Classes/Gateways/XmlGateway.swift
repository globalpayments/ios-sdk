import Foundation

class XmlGateway: Gateway {

    init() {
        super.init(contentType: "text/xml")
    }

    func doTransaction(request: String? = nil,
                       completion: @escaping (String?, Error?) -> Void) {

        sendRequest(endpoint: .empty,
                    method: .post,
                    data: request) { gatewayResponse, error in
                        guard let response = gatewayResponse else {
                            completion(nil, error)
                            return
                        }
                        if response.statusCode != 200 {
                            completion(nil, GatewayException.generic(
                                responseCode: response.statusCode,
                                responseMessage: "Unexpected http status code"
                                )
                            )
                            return
                        }
                        completion(response.rawResponse, nil)
        }
    }
}
