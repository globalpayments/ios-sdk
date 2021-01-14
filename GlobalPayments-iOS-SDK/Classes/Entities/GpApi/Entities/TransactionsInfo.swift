import Foundation

class TransactionsInfo: GpApiEntity {
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

    static func getTransactionsRequest(page: Int,
                                       pageSize: Int,
                                       fromTimeCreated: Date) -> GpApiRequest {
        return GpApiRequest(
            endpoint: "/transactions?page=\(page)&page_size=\(pageSize)&from_time_created=\(fromTimeCreated.format("yyyy-MM-dd"))",
            resultsField: "transactions"
        )
    }
}
