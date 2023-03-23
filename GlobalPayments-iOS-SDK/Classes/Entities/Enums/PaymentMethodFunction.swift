import Foundation

public enum PaymentMethodFunction: String, Mappable, CaseIterable {
    
    case primaryPayout = "PRIMARY_PAYOUT"
    case secondaryPayout = "SECONDARY_PAYOUT"
    case accountActivationFee = "ACCOUNT_ACTIVATION_FEE"
    case grossBilling = "GROSS_BILLING"
    
    public init?(value: String?) {
        guard let value = value,
              let method = PaymentMethodFunction(rawValue: value) else { return nil }
        self = method
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
