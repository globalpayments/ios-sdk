import Foundation

@objc public protocol Tokenizable {
    var token: String? { get set }

    func tokenize(configName: String,
                  completion: ((String?, Error?) -> Void)?)
    func tokenize(validateCard: Bool,
                  configName: String,
                  completion: ((String?, Error?) -> Void)?)
    func updateTokenExpiry(
        configName: String,
        completion: ((Bool, Error?) -> Void)?)
    func deleteToken(
        configName: String,
        completion: ((Bool, Error?) -> Void)?)
}
