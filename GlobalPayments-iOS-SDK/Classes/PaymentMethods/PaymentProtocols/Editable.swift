import Foundation

public protocol Editable {
    func edit(amount: NSDecimalNumber) -> AuthorizationBuilder
}
