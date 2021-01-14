import Foundation

class TransactionInfo: GpApiEntity {
    var id: String?
    var timeCreated: Date?
    var status: String?

    override func fromJson(_ doc: JsonDoc) {
        id = doc.getValue(key: "id")
        if let createdTime: String = doc.getValue(key: "time_created") {
            timeCreated = createdTime.format()
        }
        status = doc.getValue(key: "status")
    }

    static func getTransactionRequest(id: String) -> GpApiRequest {
        return GpApiRequest(endpoint: "/transactions/\(id)")
    }
}
