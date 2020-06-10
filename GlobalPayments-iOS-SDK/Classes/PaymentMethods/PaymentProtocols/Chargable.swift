import Foundation

@objc public protocol Chargeable {
    func charge(amount: Decimal) -> AuthorizationBuilder
}
