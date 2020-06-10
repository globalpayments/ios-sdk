import Foundation

@objc public protocol Editable {
    func edit(amount: Decimal) -> AuthorizationBuilder
}
