import Foundation

/// A count and amount pair, used by the Monthly Fee Report totals breakdown.
public class MonthlyFeeAmountInfo: NSObject {
    /// The total number of items.
    public var count: Int?
    /// The total amount across one or more items.
    public var amount: NSDecimalNumber?
}

/// The merchant details returned on a Monthly Fee Report record.
public class MonthlyFeeMerchant: NSObject {
    /// The full name of the merchant.
    public var name: String?
    /// The merchant's address.
    public var address: MonthlyFeeMerchantAddress?
}

/// The address of the merchant a Monthly Fee Report relates to.
public class MonthlyFeeMerchantAddress: NSObject {
    /// First line of the address.
    public var line1: String?
    /// Second line of the address.
    public var line2: String?
    /// Third line of the address.
    public var line3: String?
    /// The city associated with the address.
    public var city: String?
    /// The state or region of the address. ISO 3166-2 minus the country code itself.
    public var state: String?
    /// The postal code of the address.
    public var postalCode: String?
    /// The country of the address. ISO-3166-1 alpha-2 code.
    public var country: String?
}

/// The acquiring data identifying the merchant a Monthly Fee Report relates to.
public class MonthlyFeeSystem: NSObject {
    /// Merchant Identifier from the Global Payments system.
    public var mid: String?
    /// Identifies the location of a merchant within the merchant's corporate hierarchical structure.
    public var hierarchy: String?
    /// The merchant name associated with the merchant.
    public var name: String?
    /// The alternate name the merchant may be known as.
    public var dba: String?
}

/// A single Monthly Fee Report record.
public class MonthlyFeeSummary: NSObject {
    /// The time the report was first created.
    public var timeCreated: Date?
    /// Indicates where the report is in its lifecycle.
    public var status: MonthlyFeeStatus?
    /// The total fee amount across all amounts for the report.
    public var amount: NSDecimalNumber?
    /// The currency of the amount in ISO-4217 (alpha-3).
    public var currency: String?
    /// The total interchange amount fee for the report, set by the brands.
    public var interchangeAmount: NSDecimalNumber?
    /// The total assessment amount fee for the report, set by the brands and paid to the brands.
    public var assessmentAmount: NSDecimalNumber?
    /// The total fee amount for processing authorizations for the report.
    public var authorizationAmount: NSDecimalNumber?
    /// The total fee amount for processing disputes for the report.
    public var chargebackAmount: NSDecimalNumber?
    /// The total fee amount for paper supplies supplied by the principal or vendor.
    public var suppliesAmount: NSDecimalNumber?
    /// The total fee amount for using devices for the report.
    public var deviceAmount: NSDecimalNumber?
    /// The total discount fee amount for the report.
    public var discountAmount: NSDecimalNumber?
    /// The total of any other amounts not included in the above amount fields.
    public var otherAmount: NSDecimalNumber?
    /// The total number of items.
    public var transactionCount: Int?
    /// The sales totals for the report.
    public var sales: MonthlyFeeAmountInfo?
    /// The refunds totals for the report.
    public var refunds: MonthlyFeeAmountInfo?
    /// The passthrough totals for the report.
    public var passthrough: MonthlyFeeAmountInfo?
    /// The merchant the report was generated for.
    public var merchant: MonthlyFeeMerchant?
    /// Acquiring data used to identify the merchant.
    public var system: MonthlyFeeSystem?
}
