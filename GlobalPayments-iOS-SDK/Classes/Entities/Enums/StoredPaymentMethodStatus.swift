import Foundation

public enum StoredPaymentMethodStatus: String, Mappable {
    case active = "ACTIVE"

    public init?(value: String?) {
        guard let value = value, let type = StoredPaymentMethodStatus(value: value) else { return nil }
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
