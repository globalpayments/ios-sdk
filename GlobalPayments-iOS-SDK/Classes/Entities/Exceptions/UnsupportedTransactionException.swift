import Foundation

public enum UnsupportedTransactionException: Error {
    case generic(message: String)
}
