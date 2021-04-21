import Foundation

public class BatchSummary: NSObject {
    public var id: Int?
    public var batchReference: String?
    public var closeTransactionId: String?
    public var closeCount: Int?
    public var creditAmount: NSDecimalNumber?
    public var creditCount: Int?
    public var debitAmount: NSDecimalNumber?
    public var debitCount: Int?
    public var deviceId: String?
    public var merchantName: String?
    public var openTime: Date?
    public var openTransactionId: String?
    public var resentBatchClose: Transaction?
    public var resentTransactions: [Transaction]?
    public var responseCode: String?
    public var returnAmount: NSDecimalNumber?
    public var returnCount: Int?
    public var saleAmount: NSDecimalNumber?
    public var saleCount: Int?
    public var sequenceNumber: String?
    public var sicCode: String?
    public var siteId: String?
    public var status: String?
    public var totalAmount: NSDecimalNumber?
    public var transactionCount: Int?
    public var transactionToken: String?
}
