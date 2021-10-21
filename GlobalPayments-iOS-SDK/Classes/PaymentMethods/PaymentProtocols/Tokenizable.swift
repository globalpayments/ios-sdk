import Foundation

public protocol Tokenizable {
    var token: String? { get set }

    func tokenize(configName: String, paymentMethodUsageMode: PaymentMethodUsageMode, completion: ((String?, Error?) -> Void)?)
    func tokenize(validateCard: Bool, configName: String, paymentMethodUsageMode: PaymentMethodUsageMode, completion: ((String?, Error?) -> Void)?)
    func updateTokenExpiry(configName: String, completion: ((Bool, Error?) -> Void)?)
    func deleteToken(configName: String, completion: ((Bool, Error?) -> Void)?)
    func detokenize(configName: String, completion: ((CreditCardData?, Error?) -> Void)?)
}
