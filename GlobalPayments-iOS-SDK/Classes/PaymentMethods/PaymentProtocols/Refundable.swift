import Foundation

@objc public protocol Refundable {
    func refund(amount: Decimal) -> AuthorizationBuilder
}
