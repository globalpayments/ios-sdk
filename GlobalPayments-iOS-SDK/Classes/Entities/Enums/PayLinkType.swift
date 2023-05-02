import Foundation

public enum PayLinkType: String, Mappable {
    
    case payment
    
    public init?(value: String?) {
        guard let value = value,
              let type = PayLinkType(rawValue: value) else { return nil }
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
