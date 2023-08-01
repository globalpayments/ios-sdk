import Foundation

public enum BNPLShippingMethod: String, Mappable, CaseIterable {
    
    case DELIVERY
    case COLLECTION
    case EMAIL
    
    public init?(value: String?) {
        guard let value = value,
              let type = BNPLShippingMethod(rawValue: value) else { return nil }
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

