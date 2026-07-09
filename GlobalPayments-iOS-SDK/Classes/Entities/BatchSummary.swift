import Foundation

public class BatchAmountInfo: NSObject {
    public var count: Int?
    public var amount: NSDecimalNumber?
}

public class BatchBrandBreakdown: NSObject {
    public var brand: String?
    public var amount: NSDecimalNumber?
    public var count: Int?
    public var gratuityAmount: NSDecimalNumber?
    public var sales: BatchAmountInfo?
    public var refunds: BatchAmountInfo?
    public var fundingDebit: BatchAmountInfo?
    public var fundingCredit: BatchAmountInfo?
}

public class BatchHostBreakdown: NSObject {
    public var merchantName: String?
    public var reference: String?
    public var amount: NSDecimalNumber?
    public var count: Int?
    public var fundingDebit: BatchAmountInfo?
    public var fundingCredit: BatchAmountInfo?
}

public class BatchActionInfo: NSObject {
    public var id: String?
    public var type: String?
    public var timeCreated: Date?
    public var resultCode: String?
    public var appId: String?
    public var appName: String?
}

public class BatchSummary: NSObject {
    public var id: Int?
    public var resourceId: String?
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

    // GPAPI top-level metadata
    public var timeCreated: Date?
    public var timeLastUpdated: Date?
    public var timeClosed: Date?
    public var openActionId: String?
    public var closeActionId: String?
    public var merchantId: String?
    public var accountId: String?
    public var accountName: String?
    public var siteReference: String?
    public var deviceReference: String?
    public var currency: String?
    public var gratuityAmount: NSDecimalNumber?

    // GPAPI nested breakdown payload
    public var sales: BatchAmountInfo?
    public var refunds: BatchAmountInfo?
    public var fundingDebit: BatchAmountInfo?
    public var fundingCredit: BatchAmountInfo?
    public var brandBreakdown: [BatchBrandBreakdown]?
    public var hostBreakdown: BatchHostBreakdown?
    public var action: BatchActionInfo?
}
