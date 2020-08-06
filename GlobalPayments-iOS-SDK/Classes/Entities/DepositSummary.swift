import Foundation

public class DepositSummary {
    public var merchantHierarchy: String?
    public var merchantName: String?
    public var merchantDbaName: String?
    public var merchantNumber: String?
    public var merchantCategory: String?
    public var depositDate: Date?
    public var reference: String?
    public var amount: NSDecimalNumber?
    public var currency: String?
    public var type: String?
    public var routingNumber: String?
    public var accountNumber: String?
    public var mode: String?
    public var summaryModel: String?
    public var salesTotalCount: Int?
    public var salesTotalAmount: NSDecimalNumber?
    public var salesTotalCurrency: String?
    public var refundsTotalCount: Int?
    public var refundsTotalAmount: NSDecimalNumber?
    public var refundsTotalCurrency: String?
    public var chargebackTotalCount: Int?
    public var chargebackTotalAmount: NSDecimalNumber?
    public var chargebackTotalCurrency: String?
    public var representmentTotalCount: Int?
    public var representmentTotalAmount: NSDecimalNumber?
    public var representmentTotalCurrency: String?
    public var feesTotalAmount: NSDecimalNumber?
    public var feesTotalCurrency: String?
    public var adjustmentTotalCount: Int?
    public var adjustmentTotalAmount: NSDecimalNumber?
    public var adjustmentTotalCurrency: String?
}
