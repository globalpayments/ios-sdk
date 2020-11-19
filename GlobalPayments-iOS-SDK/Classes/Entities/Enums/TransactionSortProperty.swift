import Foundation

public enum TransactionSortProperty: String, Mappable, CaseIterable {
    case timeCreated = "TIME_CREATED"
    case status = "STATUS"
    case type = "TYPE"
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
