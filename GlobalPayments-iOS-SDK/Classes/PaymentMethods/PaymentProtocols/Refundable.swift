import Foundation

public protocol Refundable {
    func refund(amount: NSDecimalNumber?) -> AuthorizationBuilder
}
