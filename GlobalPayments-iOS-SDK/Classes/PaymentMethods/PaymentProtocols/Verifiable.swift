import Foundation

@objc public protocol Verifiable {
    func verify() -> AuthorizationBuilder
}
