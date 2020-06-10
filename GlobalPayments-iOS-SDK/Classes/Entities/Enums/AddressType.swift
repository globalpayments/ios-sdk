import Foundation

/// Indicates an address type.
@objc public enum AddressType: Int {
    /// Indicates a billing address.
    case billing
    /// Indicates a shipping address.
    case shipping
}
