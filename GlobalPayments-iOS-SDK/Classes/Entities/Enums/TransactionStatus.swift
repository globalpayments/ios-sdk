import Foundation

public enum TransactionStatus {
    case initiated
    case authenticated
    case pending
    case declined
    case preauthorized
    case captured
    case batched
    case reversed
    case funded
    case rejected
}
