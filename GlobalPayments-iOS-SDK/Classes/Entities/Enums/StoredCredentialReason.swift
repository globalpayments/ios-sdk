import Foundation

public enum StoredCredentialReason: Mappable {
    case incremental
    case resubmission
    case reauthorization
    case delayed
    case noShow

    public init?(value: String?) {
        guard let value = value else { return nil }
        switch value {
        case "INCREMENTAL":
            self = .incremental
        case "RESUBMISSION":
            self = .resubmission
        case "REAUTHORIZATION":
            self = .reauthorization
        case "DELAYED":
            self = .delayed
        case "NO_SHOW":
            self = .noShow
        default:
            return nil
        }
    }

    public func mapped(for target: Target) -> String? {
        switch target {
        case .gpApi:
            switch self {
            case .incremental:
                return "INCREMENTAL"
            case .resubmission:
                return "RESUBMISSION"
            case .reauthorization:
                return "REAUTHORIZATION"
            case .delayed:
                return "DELAYED"
            case .noShow:
                return "NO_SHOW"
            }
        default:
            return nil
        }
    }
}
