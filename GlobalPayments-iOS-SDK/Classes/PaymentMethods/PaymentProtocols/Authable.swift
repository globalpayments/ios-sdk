import Foundation

public protocol Authable {
    func authorize(amount: Decimal, isEstimated: Bool) -> AuthorizationBuilder
}
