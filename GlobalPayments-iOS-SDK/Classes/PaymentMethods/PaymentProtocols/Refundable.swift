import Foundation

public protocol Refundable {
    func refund(amount: Decimal?) -> AuthorizationBuilder
}
