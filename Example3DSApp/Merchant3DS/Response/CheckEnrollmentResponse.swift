import Foundation

protocol ApiMapperProtocol {
    associatedtype O
    func mapFromSource(_:String?) -> O
}

class CheckEnrollmentResponse: ApiMapperProtocol {
    typealias O = CheckEnrollmentResponse?
    
    var status: String?
    var serverTransactionId: String?
    var messageVersion: String?
    
    func mapFromSource(_ data: String?) -> CheckEnrollmentResponse? {
        guard let data = data else {
            return nil
        }
        let jsonDoc = JsonDoc.parse(data)
        let response = CheckEnrollmentResponse()
        response.status = jsonDoc?.getValue(key: "status")
        response.serverTransactionId = jsonDoc?.getValue(key: "serverTransactionId")
        response.messageVersion = jsonDoc?.getValue(key: "messageVersion")
        return response
    }
}
