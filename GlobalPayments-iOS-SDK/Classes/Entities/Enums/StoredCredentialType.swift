import Foundation

public enum StoredCredentialType: Mappable {
    case oneOff
    case installment
    case recurring
    case unscheduled
    case subscription
    case maintainPaymentMethod
    case maintainPaymentVerification

    public init?(value: String?) {
        guard let value = value else { return nil }
        switch value {
        case "INSTALLMENT":
            self = .installment
        case "RECURRING":
            self = .recurring
        case "UNSCHEDULED":
            self = .unscheduled
        case "SUBSCRIPTION":
            self = .subscription
        case "MAINTAIN_PAYMENT_METHOD":
            self = .maintainPaymentMethod
        case "MAINTAIN_PAYMENT_VERIFICATION":
            self = .maintainPaymentVerification
        default:
            return nil
        }
    }

    public func mapped(for target: Target) -> String? {
        switch target {
        case .gpApi:
            switch self {
            case .installment:
                return "INSTALLMENT"
            case .recurring:
                return "RECURRING"
            case .unscheduled:
                return "UNSCHEDULED"
            case .subscription:
                return "SUBSCRIPTION"
            case .maintainPaymentMethod:
                return "MAINTAIN_PAYMENT_METHOD"
            case .maintainPaymentVerification:
                return "MAINTAIN_PAYMENT_VERIFICATION"
            default:
                return nil
            }
        default:
            return nil
        }
    }
}
