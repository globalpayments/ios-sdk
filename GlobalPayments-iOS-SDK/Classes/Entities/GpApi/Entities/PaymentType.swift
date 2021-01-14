import Foundation

public enum PaymentType: String, Mappable, Encodable, CaseIterable {
    case sale = "SALE"
    case refund = "REFUND"

    public init?(value: String?) {
        guard let value = value,
              let type = PaymentType(rawValue: value) else { return nil }
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
