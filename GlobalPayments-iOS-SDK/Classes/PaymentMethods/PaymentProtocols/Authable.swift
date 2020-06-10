import Foundation

@objc public protocol Authable {
    func authorize(amount: Decimal, isEstimated: Bool) -> AuthorizationBuilder
}
