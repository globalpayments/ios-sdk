import Foundation

/// Represents a boolean field serialized as `"YES"` or `"NO"` in GP-API requests.
public enum BooleanValue: String {
    case yes = "YES"
    case no  = "NO"

    public init(_ bool: Bool) {
        self = bool ? .yes : .no
    }
}
