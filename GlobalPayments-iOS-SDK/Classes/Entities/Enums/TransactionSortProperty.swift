import Foundation

public enum TransactionSortProperty: String, Mappable, CaseIterable {
    /// Only available for Transactions report
    case id = "ID"
    /// Avalable for both Transactions and Settled Transactions report
    case timeCreated = "TIME_CREATED"
    /// Only available for Settled Transactions report
    case status = "STATUS"
    /// Avalable for both Transactions and Settled Transactions report
    case type = "TYPE"
    /// Only available for Settled Transactions report
    case depositId = "DEPOSIT_ID"

    public init?(value: String?) {
        guard let value = value,
              let sort = TransactionSortProperty(rawValue: value) else { return nil }
        self = sort
    }

    public func mapped(for target: Target) -> String? {
        switch target {
        case .gpApi:
            return self.rawValue
        default:
            return nil
        }
    }
}
