import Foundation

/// Indicates how the payment method data was obtained.
@objc public enum EntryMethod: Int {
    ///Indicates manual entry.
    case manual
    ///Indicates swipe entry.
    case swipe
    ///Indicates proximity/contactless entry.
    case proximity
}
