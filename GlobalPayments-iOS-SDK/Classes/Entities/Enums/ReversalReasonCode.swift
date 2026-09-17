import Foundation

public enum ReversalReasonCode: String, Mappable {
    case customerCancellation = "CUSTOMER_CANCELLATION"
    case duplicate = "DUPLICATE"
    case fraud = "FRAUD"
    case partialReversal = "PARTIAL_REVERSAL"
    case terminalError = "TERMINAL_ERROR"
    case timeout = "TIMEOUT"

    public func mapped(for target: Target) -> String? {
        switch target {
        case .gpApi:
            return self.rawValue
        default:
            return nil
        }
    }
}
