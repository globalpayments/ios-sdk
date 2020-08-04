import Foundation

@objc public protocol Tokenizable {
    var token: String? { get set }

    func tokenize(completion: ((String?, Error?) -> Void)?)
}
