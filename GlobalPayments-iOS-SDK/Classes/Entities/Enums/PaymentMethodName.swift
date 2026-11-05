import Foundation

public enum PaymentMethodName: String, Mappable {
    case apm
    case digitalWallet = "DIGITAL WALLET"
    case card
    case bankTransfer = "BANK TRANSFER"
    case bnpl
    case bankPayment = "BANK_PAYMENT"
    case paypal
    case cashpresso = "CASHPRESSO"
    
    public init?(value: String?) {
        guard let value = value else { return nil }
        // GP API returns payment method names upper-cased, e.g. "CARD".
        guard let status = PaymentMethodName(rawValue: value)
                ?? PaymentMethodName(rawValue: value.lowercased())
                ?? PaymentMethodName(rawValue: value.uppercased()) else { return nil }
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
