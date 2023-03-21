import Foundation

public enum PaymentMethodName: String, Mappable {
    case apm
    case digitalWallet = "DIGITAL WALLET"
    case card
    case bankTransfer = "BANK TRANSFER"

    public func mapped(for target: Target) -> String? {
        switch target {
        case .gpApi:
            return self.rawValue.uppercased()
        default:
            return nil
        }
    }
}
