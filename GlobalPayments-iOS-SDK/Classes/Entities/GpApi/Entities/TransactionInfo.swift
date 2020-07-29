import Foundation

class TransactionInfo: GpApiEntity {
    var id: String?
    var timeCreated: Date?
    var status: String?

    override func fromJson(_ doc: JsonDoc) {
        id = doc.getValue(key: "id")
        timeCreated = doc.getValue(key: "time_created")
        status = doc.getValue(key: "status")
    }

    static func getTransactionRequest(id: String) -> GpApiRequest {
        return GpApiRequest(endpoint: "/ucp/transactions/\(id)")
    }
}
