import Foundation

public protocol Chargeable {
    func charge(amount: NSDecimalNumber?) -> AuthorizationBuilder
}
