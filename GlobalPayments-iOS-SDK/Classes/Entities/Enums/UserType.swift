import Foundation

public enum UserType: String, Mappable {
    
    case merchant
    case account
    
    public init?(value: String?) {
        guard let value = value,
              let property = UserType(rawValue: value) else { return nil }
        self = property
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
