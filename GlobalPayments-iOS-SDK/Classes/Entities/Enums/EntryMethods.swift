import Foundation

/// Indicates how the payment method data was obtained.
public enum EntryMethod: String, CaseIterable {
    /// Indicates manual entry.
    case manual
    /// Indicates swipe entry.
    case swipe
    /// Indicates proximity/contactless entry.
    case proximity
}
