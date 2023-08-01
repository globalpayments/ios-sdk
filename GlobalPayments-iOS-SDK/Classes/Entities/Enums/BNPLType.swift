import Foundation

public enum BNPLType: String, Mappable, CaseIterable {
    
    case AFFIRM
    case CLEARPAY
    case KLARNA
    
    public init?(value: String?) {
        guard let value = value,
              let type = BNPLType(rawValue: value) else { return nil }
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
