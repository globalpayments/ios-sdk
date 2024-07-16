import Foundation

public enum PayByLinkSortProperty: String, Mappable {
    
    case timeCreated = "TIME_CREATED"

    public func mapped(for target: Target) -> String? {
        switch target {
        case .gpApi:
            return self.rawValue
        default:
            return nil
        }
    }
}
