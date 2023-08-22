import Foundation

public enum BankPaymentType: String, Mappable, CaseIterable {
    
    case FASTERPAYMENTS
    case SEPA
    
    public init?(value: String?) {
        guard let value = value,
              let type = BankPaymentType(rawValue: value) else { return nil }
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
