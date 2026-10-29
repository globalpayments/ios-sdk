import Foundation

public enum MonthlyFeeSortProperty: String, Mappable, CaseIterable {
    case timeCreated = "TIME_CREATED"

    public init?(value: String?) {
        guard let value = value,
              let sortProperty = MonthlyFeeSortProperty(rawValue: value) else { return nil }
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
