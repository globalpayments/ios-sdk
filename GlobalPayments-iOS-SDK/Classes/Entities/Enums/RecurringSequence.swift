import Foundation

/// Indicates when a transaction is ran in a recurring schedule.
public enum RecurringSequence {
    /// Indicates the transaction is the first of a recurring schedule.
    case first
    /// Indicates the transaction is a subsequent payment of a recurring schedule.
    case subsequent
    /// Indicates the transaction is the last of a recurring schedule.
    case last
}
