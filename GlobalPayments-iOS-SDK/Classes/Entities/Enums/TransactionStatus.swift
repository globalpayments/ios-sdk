import Foundation

public enum TransactionStatus: String, Mappable, CaseIterable {
    case initiated = "INITIATED"
    case authenticated = "AUTHENTICATED"
    case pending = "PENDING"
    case declined = "DECLINED"
    case preauthorized = "PREAUTHORIZED"
    case captured = "CAPTURED"
    case batched = "BATCHED"
    case reversed = "REVERSED"
    case funded = "FUNDED"
    case rejected = "REJECTED"
    case verified = "VERIFIED"

    public init?(value: String?) {
        guard let value = value,
              let status = TransactionStatus(rawValue: value) else { return nil }
        self = status
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
