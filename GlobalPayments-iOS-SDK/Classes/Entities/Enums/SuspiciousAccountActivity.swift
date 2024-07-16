import Foundation

public enum SuspiciousAccountActivity: String, Mappable, CaseIterable {
    
    case SUSPICIOUS_ACTIVITY
    case NO_SUSPICIOUS_ACTIVITY
    
    public init?(value: String?) {
        guard let value = value,
              let category = SuspiciousAccountActivity(rawValue: value) else { return nil }
        self = category
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
