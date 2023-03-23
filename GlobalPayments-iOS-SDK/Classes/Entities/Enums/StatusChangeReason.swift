import Foundation

public enum StatusChangeReason: String, Mappable {
    case ACTIVE
    case CLOSED_BY_MERCHANT
    case CLOSED_BY_RISK
    case APPLICATION_DENIED
    case PENDING_REVIEW
    case PENDING_MERCHANT_CONSENT
    case PENDING_IDENTITY_VALIDATION
    case PENDING_IDENTITY_VALIDATION_AND_PAYMENT
    case PENDING_PAYMENT
    case UNKNOWN_STATUS
    case REMOVE_PARTNERSHIP
    
    public func mapped(for target: Target) -> String? {
        switch target {
        case .gpApi:
            return self.rawValue
        default:
            return nil
        }
    }
}
