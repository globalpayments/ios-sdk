import Foundation

public enum PayByLinkType: String, Mappable {
    
    case payment
    case hosted_payment_page
    case third_party_page
    
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
