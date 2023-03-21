import Foundation

public enum StoredCredentialSequence: Mappable {
    case first
    case subsequent
    case last

    public init?(value: String?) {
        guard let value = value else { return nil }
        switch value {
        case "FIRST":
            self = .first
        case "SUBSEQUENT":
            self = .subsequent
        case "LAST":
            self = .last
        default:
            return nil
        }
    }

    public func mapped(for target: Target) -> String? {
        switch target {
        case .gpApi:
            switch self {
            case .first:
                return "FIRST"
            case .subsequent:
                return "SUBSEQUENT"
            case .last:
                return "LAST"
            }
        default:
            return nil
        }
    }
}
