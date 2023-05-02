import Foundation

public enum PayLinkStatus: String, Mappable {
    
    case ACTIVE
    case INACTIVE
    case CLOSED
    case EXPIRED
    case PAID
    
    public init?(value: String?) {
        guard let value = value,
              let status = PayLinkStatus(rawValue: value) else { return nil }
        self = status
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
