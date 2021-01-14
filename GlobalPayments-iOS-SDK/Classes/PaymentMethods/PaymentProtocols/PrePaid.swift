import Foundation

public protocol PrePaid {
    func addValue(amount: NSDecimalNumber?) -> AuthorizationBuilder
}
