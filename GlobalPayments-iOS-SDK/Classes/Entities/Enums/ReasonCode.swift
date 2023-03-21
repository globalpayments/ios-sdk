import Foundation

/// Indicates a reason for the transaction.
/// This is typically used for returns/reversals.
public enum ReasonCode: String {
    /// Indicates fraud.
    case fraud = "FRAUD"
    /// Indicates a false positive.
    case falsePositive = "FALSE_POSITIVE"
    /// Indicates desired good is out of stock.
    case outOfStock = "OUT_OF_STOCK"
    /// Indicates desired good is in of stock.
    case inStock = "IN_STOCK"
    /// Indicates another reason.
    case other = "OTHER"
    /// Indicates reason was not given.
    case notGiven = "NOT_GIVEN"
}
