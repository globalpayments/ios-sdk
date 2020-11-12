import Foundation

/// Indicates CVN presence at time of payment
public enum CvnPresenceIndicator: String, Mappable {
    /// Indicates CVN was present
    case present = "PRESENT"
    /// Indicates CVN was present but illegible
    case illegible = "ILLEGIBLE"
    /// Indicates CVN was not present
    case notOnCard = "NOT_PRESENT"
    /// Indicates CVN was not requested
    case notRequested

    public func mapped(for target: Target) -> String? {
        switch target {
        case .gpApi:
            switch self {
            case .present, .illegible, .notOnCard:
                return self.rawValue
            default:
                return nil
            }
        default:
            return nil
        }
    }
}
