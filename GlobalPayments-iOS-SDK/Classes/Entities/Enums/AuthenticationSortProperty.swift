import Foundation

public enum AuthenticationSortProperty: String, Mappable, CaseIterable {
    case timeCreated = "TIME_CREATED"
    case id = "ID"
    case status = "STATUS"

    public init?(value: String?) {
        guard let value = value,
              let property = AuthenticationSortProperty(rawValue: value) else { return nil }
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
