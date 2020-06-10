import Foundation

/// Indicates the account type for ACH/eCheck transactions.
@objc public enum AccountType: Int {
    /// Indicates a checking account.
    case checking
    /// Indicates a savings account.
    case savings
}
