import Foundation

public enum StoredPaymentMethodSortProperty: String, Mappable, CaseIterable {
    case timeCreated = "TIME_CREATED"

    public init?(value: String?) {
        guard let value = value, let type = StoredPaymentMethodSortProperty(value: value) else { return nil }
        self = type
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
