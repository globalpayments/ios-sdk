import Foundation

@objc public protocol Tokenizable {
    var token: String? { get set }

    func tokenize() -> String?
}
