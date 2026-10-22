import Foundation

/// Indicates the reason why a prepaid card needs to be replaced.
public enum CardReplacementReason: String, Mappable {
    /// The card has either been lost or stolen. This will immediately disable the currently-assigned card and issue a new card with a new number.
    case LOST
    
    public func mapped(for target: Target) -> String? {
        switch target {
        case .gpApi:
            return self.rawValue
        default:
            return nil
        }
    }
}
