import Foundation

/// Identifies who initiated the BLIK payment code (e.g. for BLIK Level 0).
public enum PaymentCodeInitiator: String, Mappable, CaseIterable {

    case payer
    case merchant

    public init?(value: String?) {
        guard let value = value,
              let initiator = PaymentCodeInitiator(rawValue: value) else { return nil }
        self = initiator
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
