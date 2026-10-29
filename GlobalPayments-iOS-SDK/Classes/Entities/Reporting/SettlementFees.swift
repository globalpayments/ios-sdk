import Foundation

/// A specific type of assessment charge associated with a settled transaction.
/// There can be more than one assessment charge associated with a transaction.
public class SettlementFeeAssessment: NSObject {
    /// The description for this assessment charge. Named `chargeDescription` as
    /// `description` is already defined on `NSObject`.
    public var chargeDescription: String?
    /// The percentage of the transaction amount used to calculate this assessment charge.
    public var percentage: String?
    /// The amount for this assessment charge represented as a decimal of the lowest denomination of the currency.
    public var amount: NSDecimalNumber?
}

/// A breakdown of the interchange fees associated with a settled transaction.
public class SettlementFeeInterchange: NSObject {
    /// The total interchange amount represented as a decimal of the lowest denomination of the currency.
    public var totalAmount: NSDecimalNumber?
    /// The total interchange rate.
    public var totalRate: String?
    /// The name of the interchange program applied to the transaction.
    public var program: String?
    /// The percentage of the transaction amount charged as interchange for this transaction.
    public var percentage: String?
    /// The interchange amount derived from a percentage of the transaction amount.
    public var percentageAmount: NSDecimalNumber?
    /// The amount charged based on the number of items bought.
    public var perItemFlatAmount: NSDecimalNumber?
    /// The amount charged based on one or many aspects of the transaction.
    public var perItemCalculatedAmount: NSDecimalNumber?
}

/// A breakdown of the discount fees associated with a settled transaction.
public class SettlementFeeDiscount: NSObject {
    /// The discount percentage charged based on the rate number.
    public var rate1Percentage: String?
    /// The discount percentage charged based on the rate number.
    public var rate2Percentage: String?
    /// The total discount amount for this transaction.
    public var totalAmount: NSDecimalNumber?
}

/// A list of percentage mark ups on any currency conversion services for a settled transaction.
public class SettlementFeeMarkUp: NSObject {
    /// The markup percentage charged for DCC, Dynamic Currency Conversion.
    public var dccPercentage: String?
    /// The markup percentage charged for Multi-Currency processing.
    public var multicurrencyPercentage: String?
}

/// A breakdown of the fees associated with a settled transaction.
public class SettlementFees: NSObject {
    /// The total fee amount for this transaction.
    public var totalAmount: NSDecimalNumber?
    /// The total amount of other fees that don't fit into assessment, interchange, discount or markup.
    public var otherFeesAmount: NSDecimalNumber?
    /// The fixed amount that is charged per transaction. Applicable for BNPL transactions only.
    public var fixedAmount: NSDecimalNumber?
    /// Tax on merchant fees. Applicable for BNPL transactions only.
    public var taxAmount: NSDecimalNumber?
    /// The total assessment fee amount for this transaction.
    public var assessmentTotalAmount: NSDecimalNumber?
    /// A Global Payments charge code applied to this transaction.
    public var chargeType: String?
    /// A description that explains the Global Payments charge applied to this transaction.
    public var chargeTypeDescription: String?
    /// The region the card used for the transaction was issued in.
    public var chargeTypeRegion: String?
    /// The exchange rate used to convert the total fee amount to the currency of the merchant.
    public var exchangeRate: String?
    /// A breakdown of the interchange fees associated with the transaction.
    public var interchange: SettlementFeeInterchange?
    /// A breakdown of the discount fees associated with the transaction.
    public var discount: SettlementFeeDiscount?
    /// A specific type of assessment charge for the transaction.
    public var assessment1: SettlementFeeAssessment?
    /// A specific type of assessment charge for the transaction.
    public var assessment2: SettlementFeeAssessment?
    /// A specific type of assessment charge for the transaction.
    public var assessment3: SettlementFeeAssessment?
    /// A specific type of assessment charge for the transaction.
    public var assessment4: SettlementFeeAssessment?
    /// A specific type of assessment charge for the transaction.
    public var assessment5: SettlementFeeAssessment?
    /// A list of percentage mark ups on any currency conversion services for this transaction.
    public var markUp: SettlementFeeMarkUp?
}
