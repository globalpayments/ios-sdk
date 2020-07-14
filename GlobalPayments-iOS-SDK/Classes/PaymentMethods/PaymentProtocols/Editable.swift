import Foundation

public protocol Editable {
    func edit(amount: Decimal) -> AuthorizationBuilder
}
