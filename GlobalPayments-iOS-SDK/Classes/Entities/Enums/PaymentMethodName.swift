import Foundation

public enum PaymentMethodName: String, Mappable {
    case apm
    case digitalWallet = "DIGITAL WALLET"
    case card
    case bankTransfer = "BANK TRANSFER"
    case bnpl
    case bankPayment = "BANK_PAYMENT"
    
    public init?(value: String?) {
        guard let value = value,
              let status = PaymentMethodName(rawValue: value) else { return nil }
        self = status
    }

    public func mapped(for target: Target) -> String? {
        switch target {
        case .gpApi:
            return self.rawValue.uppercased()
        default:
            return nil
        }
    }
}
