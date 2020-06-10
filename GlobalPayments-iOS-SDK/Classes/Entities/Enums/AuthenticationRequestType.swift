import Foundation

@objc public enum AuthenticationRequestType: Int {
    case paymentTransaction
    case recurringTransaction
    case installmentTransaction
    case addCard
    case maintainCard
    case cardholderVerification
}
