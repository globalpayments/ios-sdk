import Foundation

public enum StoredCredentialInitiator: Mappable {
    case cardHolder
    case merchant
    case scheduled

    public init?(value: String?) {
        guard let value = value else { return nil }
        switch value {
        case "C", "PAYER":
            self = .cardHolder
        case "M", "MERCHANT":
            self = .merchant
        default:
            return nil
        }
    }

    public func mapped(for target: Target) -> String? {
        switch target {
        case .gpApi:
            switch self {
            case .cardHolder:
                return "PAYER"
            case .merchant:
                return "MERCHANT"
            default:
                return nil
            }
        case .portico:
            switch self {
            case .cardHolder:
                return "C"
            case .merchant:
                return "M"
            default:
                return nil
            }
        default:
            return nil
        }
    }
}
