import Foundation

public enum FraudFilterResult: String, Mappable, CaseIterable {
    
    case HOLD = "PENDING_REVIEW"
    case PASS = "ACCEPTED"
    case BLOCK = "REJECTED"
    case NOT_EXECUTED
    case ERROR
    case RELEASE_SUCCESSFULL
    case HOLD_SUCCESSFULL

    public init?(value: String?) {
        guard let value = value,
              let status = FraudFilterResult(rawValue: value) else { return nil }
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
