import Foundation

public enum PayByLinkType: String, Mappable {
    
    /// Standard payment link.
    case payment
    /// Hosted payment page link.
    case hosted_payment_page
    /// Third-party payment page link.
    case third_party_page
    /// Link for exchanging application credentials.
    case EXCHANGE_APP_CREDENTIALS
    
    public init?(value: String?) {
        guard let value = value,
              let type = PayByLinkType(rawValue: value) else { return nil }
        self = type
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
