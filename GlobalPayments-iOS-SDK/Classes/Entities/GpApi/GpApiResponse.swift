import Foundation

class BaseGpApiResponse {
    var totalCount: Int?
    var merchantId: String?
    var merchantName: String?
    var accountId: String?
    var accountName: String?
    var rawResults: [JsonDoc]?

    private var resultsField: String

    init(rawResponse: String, resultsField: String) {
        self.resultsField = resultsField
        let doc = JsonDoc.parse(rawResponse)
        mapResponseValues(doc)
    }

    func mapResponseValues(_ doc: JsonDoc?) {
        totalCount = doc?.getValue(key: "total_count")
        merchantId = doc?.getValue(key: "merchant_id")
        merchantName = doc?.getValue(key: "merchant_name")
        accountId = doc?.getValue(key: "account_id")
        accountName = doc?.getValue(key: "account_name")
        if !resultsField.isEmpty {
            rawResults = doc?.getEnumerator(key: resultsField)
        }
    }
}

class GpApiResponse<T: GpApiEntity>: BaseGpApiResponse {
    var results: [T]

    override init(rawResponse: String, resultsField: String) {
        results = [T]()
        super.init(rawResponse: rawResponse, resultsField: resultsField)
        if let rawResults = rawResults {
            for result in rawResults {
                let item = T()
                item.fromJson(result)
                results.append(item)
            }
        }
    }
}
