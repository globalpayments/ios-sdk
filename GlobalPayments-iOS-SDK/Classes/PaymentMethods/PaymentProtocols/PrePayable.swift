import Foundation

@objc public protocol PrePayable {
    func addValue(amount: Decimal) -> AuthorizationBuilder
}
