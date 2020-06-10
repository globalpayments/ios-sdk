import Foundation

/// Indicates the type of recurring schedule.
@objc public enum RecurringType: Int {
    /// Indicates a fix number of payments.
    case fixed
    /// Indicates a variable number of payments.
    case variable
}
