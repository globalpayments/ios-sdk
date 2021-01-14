import Foundation

public enum SortDirection: String, Mappable, CaseIterable {
    case ascending = "ASC"
    case descending = "DESC"

    public init?(value: String?) {
        guard let value = value,
              let direction = SortDirection(rawValue: value) else { return nil }
        self = direction
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
