import Foundation

public enum VoidReason: String, Mappable {
    case postAuthUserDeclined = "POST_AUTH_USER_DECLINE"
    case deviceTimeout = "DEVICE_TIMEOUT"
    case deviceUnavailable = "DEVICE_UNAVAILABLE"
    case partialReversal = "PARTIAL_REVERSAL"
    case tornTransactions = "TORN_TRANSACTIONS"
    case postAuthChipDecline = "POST_AUTH_CHIP_DECLINE"

    public func mapped(for target: Target) -> String? {
        switch target {
        case .transit:
            return self.rawValue
        default:
            return nil
        }
    }
}
