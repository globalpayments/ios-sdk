import Foundation

/// Indicates the check type for ACH/eCheck transactions.
public enum CheckType {
    /// Indicates a personal check.
    case personal
    /// Indicates a business check.
    case business
    /// Indicates a payroll check.
    case payroll
}
