import Foundation

/// The payment methods an account is configured for.
public enum AccountPaymentMethod: String, Mappable, CaseIterable, Codable {
    case card = "CARD"
    case digitalWallet = "DIGITAL_WALLET"
    case bankTransfer = "BANK_TRANSFER"
    case apm = "APM"
    case paypal = "PAYPAL"

    public init?(value: String?) {
        guard let value = value,
              let property = AccountPaymentMethod(rawValue: value) else { return nil }
        self = property
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
