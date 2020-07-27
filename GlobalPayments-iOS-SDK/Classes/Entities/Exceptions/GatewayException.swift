import Foundation

public enum GatewayException: Error {
    case generic(responseCode: Int, responseMessage: String?)
}
