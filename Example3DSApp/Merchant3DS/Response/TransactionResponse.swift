import Foundation

class TransactionResponse: ApiMapperProtocol {
    typealias O = TransactionResponse?
    var status: String?
    var transactionId: String?
    var amount: String?
    var date: String?
    var responseCode: String?
    var responseMessage: String?
    var reference: String?
    var batchId: String?
    
    func mapFromSource(_ data: String?) -> TransactionResponse? {
        guard let data = data else {
            return nil
        }
        let jsonDoc = JsonDoc.parse(data)
        let response = TransactionResponse()
        response.status = jsonDoc?.getValue(key: "status")
        response.transactionId = jsonDoc?.getValue(key: "transactionId")
        response.amount = jsonDoc?.getValue(key: "amount")
        response.date = jsonDoc?.getValue(key: "date")
        response.responseCode = jsonDoc?.getValue(key: "responseCode")
        response.responseMessage = jsonDoc?.getValue(key: "responseMessage")
        response.reference = jsonDoc?.getValue(key: "reference")
        response.batchId = jsonDoc?.getValue(key: "batchId")
        return response
    }
}
