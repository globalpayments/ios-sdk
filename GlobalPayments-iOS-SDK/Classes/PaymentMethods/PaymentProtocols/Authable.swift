import Foundation

public protocol Authable {
    func authorize(amount: NSDecimalNumber?, isEstimated: Bool) -> AuthorizationBuilder
}
