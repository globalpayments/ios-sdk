import Foundation

public enum PhoneNumberType: String, Mappable, CaseIterable {
    
    case Home
    case Work
    case Shipping
    case Mobile
    
    public init?(value: String?) {
        guard let value = value,
              let type = PhoneNumberType(rawValue: value) else { return nil }
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
