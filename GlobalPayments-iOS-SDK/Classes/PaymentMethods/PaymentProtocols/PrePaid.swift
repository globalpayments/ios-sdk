import Foundation

@objc public protocol PrePaid {
    func addValue(amount: Decimal) -> AuthorizationBuilder
}
