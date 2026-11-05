import Foundation

public class DccBinRangeSummary {
    public var lowPrefixNumber: String?
    public var highPrefixNumber: String?
    public var status: String?
}

public class DccBinRangeResponse {
    public var timeCreated: Date?
    public var isLastPage: Bool?
    public var timeRetrieved: String?
    public var currentIndex: Int?
    public var currentPageSize: Int?
    public var merchantId: String?
    public var merchantName: String?
    public var accountId: String?
    public var accountName: String?
    public var country: String?
    public var merchantCurrency: String?
    public var payerCurrency: [String]?
    public var binRanges: [DccBinRangeSummary]?
    public var action: ActionSummary?
}
