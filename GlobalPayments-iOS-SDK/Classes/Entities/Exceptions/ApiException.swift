import Foundation

/// A general error occurred.
public struct ApiException: Error {
    /// The exception message
    public let message: String?

    public init(message: String? = nil) {
        self.message = message
    }
}
