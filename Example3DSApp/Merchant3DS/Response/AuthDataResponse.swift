import Foundation

class AuthDataResponse: ApiMapperProtocol {
    typealias O = AuthDataResponse?
    var status: String?
    var serverTransactionId: String?
    var liabilityShift: String?
    
    func mapFromSource(_ data: String?) -> AuthDataResponse? {
        guard let data = data else {
            return nil
        }
        let jsonDoc = JsonDoc.parse(data)
        let response = AuthDataResponse()
        response.status = jsonDoc?.getValue(key: "status")
        response.serverTransactionId = jsonDoc?.getValue(key: "serverTransactionId")
        response.liabilityShift = jsonDoc?.getValue(key: "liabilityShift")
        return response
    }
}
