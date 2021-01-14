import Foundation

/// An account or SDK configuration error occurred.
public struct ConfigurationException: Error {
    /// The exception message
    public let message: String?
    
    public init(message: String? = nil) {
        self.message = message
    }
}
