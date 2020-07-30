import Foundation

/// Indicates a reason for the transaction.
/// This is typically used for returns/reversals.
public enum ReasonCode {
    /// Indicates fraud.
    case fraud
    /// Indicates a false positive.
    case falsePositive
    /// Indicates desired good is out of stock.
    case outOfStock
    /// Indicates desired good is in of stock.
    case inStock
    /// Indicates another reason.
    case other
    /// Indicates reason was not given.
    case notGiven
}
