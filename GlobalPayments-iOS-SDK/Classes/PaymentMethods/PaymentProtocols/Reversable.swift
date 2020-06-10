import Foundation

@objc public protocol Reversable {
    func reverse(amount: Decimal) -> AuthorizationBuilder
}
