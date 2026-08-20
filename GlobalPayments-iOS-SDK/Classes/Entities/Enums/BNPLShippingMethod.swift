import Foundation

public enum BNPLShippingMethod: String, Mappable, CaseIterable {
    
    case DELIVERY
    case COLLECTION
    case EMAIL
    // Cashpresso-specific shipping methods
    case PICKUP
    case PICKUP_BOX
    case POSTOFFICE
    
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

