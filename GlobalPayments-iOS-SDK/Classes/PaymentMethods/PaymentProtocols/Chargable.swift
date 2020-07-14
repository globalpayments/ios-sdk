import Foundation

public protocol Chargeable {
    func charge(amount: Decimal) -> AuthorizationBuilder
}
