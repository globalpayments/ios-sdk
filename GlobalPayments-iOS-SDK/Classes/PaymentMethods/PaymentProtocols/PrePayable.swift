import Foundation

public protocol PrePayable {
    func addValue(amount: NSDecimalNumber) -> AuthorizationBuilder
}
