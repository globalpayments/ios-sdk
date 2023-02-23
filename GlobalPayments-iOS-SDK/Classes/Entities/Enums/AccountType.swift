import Foundation

/// Indicates the account type for ACH/eCheck transactions.
public enum AccountType: String, Mappable, CaseIterable {
    /// Indicates a checking account.
    case checking
    /// Indicates a saving account.
    case saving
    /// Indicates a credit account.
    case credit

    public func mapped(for target: Target) -> String? {
        switch target {
        case .gpApi:
            return self.rawValue.uppercased()
        default:
            return nil
        }
    }
}
