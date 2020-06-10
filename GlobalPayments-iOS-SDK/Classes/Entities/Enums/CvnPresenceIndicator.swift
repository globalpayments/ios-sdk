import Foundation

/// Indicates CVN presence at time of payment
@objc public enum CvnPresenceIndicator: Int {
    /// Indicates CVN was present
    case present
    /// Indicates CVN was present but illegible
    case illegible
    /// Indicates CVN was not present
    case notOnCard
    /// Indicates CVN was not requested
    case notRequested
}
