import Foundation

public protocol Tokenizable {
    var token: String? { get set }

    func tokenize(completion: ((String?) -> Void)?)
}
