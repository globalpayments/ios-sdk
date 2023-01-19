import Foundation

class AccessTokenResponse: ApiMapperProtocol {
    typealias O = AccessTokenResponse?
    var accessToken: String?
    
    func mapFromSource(_ data: String?) -> AccessTokenResponse? {
        guard let data = data else {
            return nil
        }
        let jsonDoc = JsonDoc.parse(data)
        let response = AccessTokenResponse()
        response.accessToken = jsonDoc?.getValue(key: "accessToken")
        return response
    }
}
