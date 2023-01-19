import Foundation

class AuthParamsResponse: ApiMapperProtocol {
    typealias O = AuthParamsResponse?
    var status: String?
    var serverTransactionId: String?
    var dsTransferReference: String?
    var liabilityShift: String?
    var acsTransactionId: String?
    var acsReferenceNumber: String?
    var payerAuthenticationRequest: String?
    
    func mapFromSource(_ data: String?) -> AuthParamsResponse? {
        guard let data = data else {
            return nil
        }
        let jsonDoc = JsonDoc.parse(data)
        let response = AuthParamsResponse()
        response.status = jsonDoc?.getValue(key: "status")
        response.serverTransactionId = jsonDoc?.getValue(key: "serverTransactionId")
        response.dsTransferReference = jsonDoc?.getValue(key: "dsTransferReference")
        response.liabilityShift = jsonDoc?.getValue(key: "liabilityShift")
        response.acsTransactionId = jsonDoc?.getValue(key: "acsTransactionId")
        response.acsReferenceNumber = jsonDoc?.getValue(key: "acsReferenceNumber")
        response.payerAuthenticationRequest = jsonDoc?.getValue(key: "payerAuthenticationRequest")
        return response
    }

}
