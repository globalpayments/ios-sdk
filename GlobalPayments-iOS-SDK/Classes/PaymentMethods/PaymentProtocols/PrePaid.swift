import Foundation

public protocol PrePaid {
    func addValue(amount: Decimal) -> AuthorizationBuilder
}
