import Foundation

public class DepositSummary {
    public var merchantHierarchy: String?
    public var merchantName: String?
    public var merchantDbaName: String?
    public var merchantNumber: String?
    public var merchantCategory: String?
    public var depositDate: Date?
    public var reference: String?
    public var amount: Decimal?
    public var currency: String?
    public var type: String?
    public var routingNumber: String?
    public var accountNumber: String?
    public var mode: String?
    public var summaryModel: String?
    public var salesTotalCount: Int?
    public var salesTotalAmount: Decimal?
    public var salesTotalCurrency: String?
    public var refundsTotalCount: Int?
    public var refundsTotalAmount: Decimal?
    public var refundsTotalCurrency: String?
    public var chargebackTotalCount: Int?
    public var chargebackTotalAmount: Decimal?
    public var chargebackTotalCurrency: String?
    public var representmentTotalCount: Int?
    public var representmentTotalAmount: Decimal?
    public var representmentTotalCurrency: String?
    public var feesTotalAmount: Decimal?
    public var feesTotalCurrency: String?
    public var adjustmentTotalCount: Int?
    public var adjustmentTotalAmount: Decimal?
    public var adjustmentTotalCurrency: String?
}
