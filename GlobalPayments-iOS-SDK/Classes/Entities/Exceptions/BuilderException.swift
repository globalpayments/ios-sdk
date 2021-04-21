import Foundation

/// A builder error occurred. Check the method calls against the builder.
public struct BuilderException: Error {
    /// The exception message
    public let message: String?

    public init(message: String? = nil) {
        self.message = message
    }
}
