import Foundation

public class BatchTransactionsSummary: NSObject {
    public var totalRecordCount: Int?
    public var batchTransactionCount: Int?
    public var merchantId: String?
    public var merchantName: String?
    public var accountId: String?
    public var accountName: String?
    public var siteReference: String?
    public var deviceReference: String?
    public var filterBatchId: String?
    public var transactions: [TransactionSummary]?
    public var action: BatchActionInfo?
}
