import Foundation

public enum SortDirection: String, Mappable {
    case ascending = "ASC"
    case descending = "DESC"

    public func mapped(for target: Target) -> String? {
        switch target {
        case .gpApi:
            return self.rawValue
        default:
            return nil
        }
    }
}
