import Foundation

public protocol Verifiable {
    func verify() -> AuthorizationBuilder
}
