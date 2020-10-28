import Foundation

public enum GpApiTransactionType: String, Mappable, Encodable {
    case sale = "SALE"
    case refund = "REFUND"

    init?(value: String?) {
        guard let value = value,
              let type = GpApiTransactionType(rawValue: value) else { return nil }
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
