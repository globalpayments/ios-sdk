import Foundation

public enum StoredCredentialType: String, Mappable {
    case installment = "INSTALLMENT"
    case recurring = "RECURRING"
    case unscheduled = "UNSCHEDULED"
    case subscription = "SUBSCRIPTION"
    case maintainPaymentMethod = "MAINTAIN_PAYMENT_METHOD"
    case maintainPaymentVerification = "MAINTAIN_PAYMENT_VERIFICATION"

    public init?(value: String?) {
        guard let value = value, let type = StoredCredentialType(value: value) else { return nil }
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
