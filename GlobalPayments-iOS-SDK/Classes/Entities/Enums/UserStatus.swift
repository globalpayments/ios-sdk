import Foundation

public enum UserStatus: String, Mappable, CaseIterable {
    
    case ACTIVE
    case INACTIVE
    case UNDER_REVIEW
    case DECLINED
    
    public init?(value: String?) {
        guard let value = value,
              let property = UserStatus(rawValue: value) else { return nil }
        self = property
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
