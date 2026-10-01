import Foundation

public class ReportAmountInfo: NSObject {
    public var count: Int?
    public var amount: NSDecimalNumber?
}

public class ReportPaymentMethodBreakdown: NSObject {
    public var category: PaymentMethodCategory?
    public var brand: String?
    public var count: Int?
    public var amount: Int64?
    public var gratuityAmount: Int?
    public var sales: ReportAmountInfo?
    public var refunds: ReportAmountInfo?
    public var reversals: ReportAmountInfo?
}

public class TransactionSummaryReport: NSObject {
    public var type: String?
    public var sales: ReportAmountInfo?
    public var refunds: ReportAmountInfo?
    public var paymentMethodBreakdown: [ReportPaymentMethodBreakdown]?
}
