import Foundation

/// The payment method category used in the Transaction.
public enum PaymentMethodCategory: String, Mappable {
    case card = "CARD"
    case apm = "APM"
    case digitalWallets = "DIGITAL_WALLETS"
    case bankTransfer = "BANK_TRANSFER"
    case unknown = "UNKNOWN"

    public init?(value: String?) {
        guard let value = value,
              let category = PaymentMethodCategory(rawValue: value.uppercased()) else { return nil }
        self = category
    }

    public func mapped(for target: Target) -> String? {
        switch target {
        case .gpApi:
            return rawValue
        default:
            return nil
        }
    }
}
