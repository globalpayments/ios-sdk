import Foundation

/// Indicates when an email receipt should be sent for the transaction.
/// Currently only used in recurring schedules.
@objc public enum EmailReceipt: Int {
    /// Indicates an email receipt should never be sent.
    case never
    /// Indicates an email receipt should always be sent.
    case all
    /// Indicates an email receipt should only be sent on approvals.
    case approvals
    /// Indicates an email receipt should only be sent on declines.
    case declines
}
