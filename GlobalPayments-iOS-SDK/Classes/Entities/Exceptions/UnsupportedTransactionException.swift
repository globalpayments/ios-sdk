import Foundation

/// The built transaction is not supported for the gateway or payment method.
public struct UnsupportedTransactionException: Error {
    /// The exception message
    public let message: String?
    
    public init(message: String? = nil) {
        self.message = message
    }
}
