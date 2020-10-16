import Foundation

public class DepositSummary {
    /// A unique identifier to identify the Deposit
    public var depositId: String?
    /// Identifies the location of a merchant identifier within the merchant's hierarchical structure.
    public var merchantHierarchy: String?
    /// The merchant name that is associated with the merchant
    public var merchantName: String?
    /// The alternate name the merchant may be known as.
    public var merchantDbaName: String?
    /// Merchant Identifier
    public var merchantNumber: String?
    public var merchantCategory: String?
    /// Global Payments time indicating when the Deposit was created.
    public var depositDate: Date?
    public var reference: String?
    /// The amount of the Deposit that affects the Merchant's bank account
    public var amount: NSDecimalNumber?
    /// The currency of the amount.
    public var currency: String?
    /// Indicates if the Deposit was a Debit or Credit to the Merchants bank account
    public var type: String?
    public var routingNumber: String?
    public var accountNumber: String?
    public var mode: String?
    public var summaryModel: String?
    /// The total number of items
    public var salesTotalCount: Int?
    /// The total amount in the currency of the Deposit
    public var salesTotalAmount: NSDecimalNumber?
    public var salesTotalCurrency: String?
    public var status: String?
    /// The total number of items
    public var refundsTotalCount: Int?
    /// The total amount in the currency of the Deposit
    public var refundsTotalAmount: NSDecimalNumber?
    public var refundsTotalCurrency: String?
    /// The total number of items
    public var chargebackTotalCount: Int?
    /// The total amount in the currency of the Deposit.
    public var chargebackTotalAmount: NSDecimalNumber?
    public var chargebackTotalCurrency: String?
    public var representmentTotalCount: Int?
    public var representmentTotalAmount: NSDecimalNumber?
    public var representmentTotalCurrency: String?
    /// The total amount in the currency of the Deposit
    public var feesTotalAmount: NSDecimalNumber?
    public var feesTotalCurrency: String?
    public var adjustmentTotalCount: Int?
    public var adjustmentTotalAmount: NSDecimalNumber?
    public var adjustmentTotalCurrency: String?
}
