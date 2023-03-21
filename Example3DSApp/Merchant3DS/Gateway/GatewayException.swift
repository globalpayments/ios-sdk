import Foundation

public struct GatewayException: Error {
    public let message: String?
    public let responseCode: String?
    public let responseMessage: String?

    public init(message: String? = nil,
                responseCode: String? = nil,
                responseMessage: String? = nil) {

        self.message = message
        self.responseCode = responseCode
        self.responseMessage = responseMessage
    }
}
