import Foundation

public enum PaymentProvider: String, Mappable, CaseIterable {
    
    case OPEN_BANKING = "open_banking"
    
    public init?(value: String?) {
        guard let value = value,
              let type = PaymentProvider(rawValue: value) else { return nil }
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
