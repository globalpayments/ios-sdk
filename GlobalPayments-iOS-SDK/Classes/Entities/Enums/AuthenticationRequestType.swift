import Foundation

public enum AuthenticationRequestType {
    case paymentTransaction
    case recurringTransaction
    case installmentTransaction
    case addCard
    case maintainCard
    case cardholderVerification
}
