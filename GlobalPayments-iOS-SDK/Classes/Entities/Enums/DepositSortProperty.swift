import Foundation

public enum DepositSortProperty: String, Mappable, CaseIterable {
    case timeCreated = "TIME_CREATED"
    case status = "STATUS"
    case type = "TYPE"
    case depositId = "DEPOSIT_ID"

    public init?(value: String?) {
        guard let value = value,
              let sortProperty = DepositSortProperty(rawValue: value) else { return nil }
        self = sortProperty
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
