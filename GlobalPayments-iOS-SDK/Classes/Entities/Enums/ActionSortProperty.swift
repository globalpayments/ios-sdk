import Foundation

public enum ActionSortProperty: String, Mappable {
    case timeCreated = "TIME_CREATED"

    public init?(value: String?) {
        guard let value = value,
              let property = ActionSortProperty(rawValue: value) else { return nil }
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
