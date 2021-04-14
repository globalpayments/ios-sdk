import Foundation

@objc public protocol Tokenizable {
    var token: String? { get set }

    func tokenize(configName: String, idempotencyKey: String?, completion: ((String?, Error?) -> Void)?)
    func tokenize(validateCard: Bool, configName: String, idempotencyKey: String?, completion: ((String?, Error?) -> Void)?)
    func updateTokenExpiry(configName: String, idempotencyKey: String?, completion: ((Bool, Error?) -> Void)?)
    func deleteToken(configName: String, idempotencyKey: String?, completion: ((Bool, Error?) -> Void)?)
    func detokenize(configName: String, idempotencyKey: String?, completion: ((CreditCardData?, Error?) -> Void)?)
}
