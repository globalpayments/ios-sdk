import Foundation

public enum TransactionStatus: String, Mappable {
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

    public func mapped(for target: Target) -> String? {
        switch target {
        case .gpApi:
            return self.rawValue
        default:
            return nil
        }
    }
}
