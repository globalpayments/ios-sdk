import Foundation

class ApiConnector: RestGateway3ds {
    
    func doRequestData(method: HTTPMethod,
                       endpoint: String,
                       data: String? = nil,
                       queryStringParams: [String: String]? = nil,
                       completion: @escaping (String?, Error?) -> Void) {

        super.doRequest(
            method: method,
            endpoint: endpoint,
            data: data,
            queryStringParams: queryStringParams) { response, error in
            completion(response, error)
        }
    }
}
