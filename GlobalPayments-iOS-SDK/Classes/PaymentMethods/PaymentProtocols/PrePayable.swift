import Foundation

public protocol PrePayable {
    func addValue(amount: Decimal) -> AuthorizationBuilder
}
