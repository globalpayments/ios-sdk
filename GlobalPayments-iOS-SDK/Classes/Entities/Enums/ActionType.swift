import Foundation

public enum ActionType: String, Mappable {
    
    case linkCreate = "LINK_CREATE"
    case linkEdit = "LINK_EDIT"
    
    public init?(value: String?) {
        guard let value = value,
              let status = ActionType(rawValue: value) else { return nil }
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
