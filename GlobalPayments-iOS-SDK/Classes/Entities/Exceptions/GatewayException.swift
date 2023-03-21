import Foundation

/// An error occurred on the gateway.
public struct GatewayException: Error {
    /// The exception message
    public let message: String?
    /// The gateway response code.
    public let responseCode: String?
    /// The gateway response message.
    public let responseMessage: String?

    public init(message: String? = nil,
                responseCode: String? = nil,
                responseMessage: String? = nil) {

        self.message = message
        self.responseCode = responseCode
        self.responseMessage = responseMessage
    }
}
