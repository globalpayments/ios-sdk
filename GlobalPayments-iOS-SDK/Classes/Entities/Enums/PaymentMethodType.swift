import Foundation

/// Indicates a payment method type.
public struct PaymentMethodType: OptionSet, Hashable {
    public let rawValue: Int
    public var value: String = ""
    
    public init(rawValue: Int) {
        self.rawValue = rawValue
    }

    public init(rawValue: Int, value: String = "") {
        self.init(rawValue: rawValue)
        self.value = value
    }
    
    /// Indicates a payment method reference.
    /// - Description: Should be accompanied by a gateway transaction ID.
    public static let reference = PaymentMethodType(rawValue: 1 << 0)
    /// Indicates a credit or PIN-less debit account.
    /// - Description: Should be accompanied by a token, card number, or track data.
    public static let credit    = PaymentMethodType(rawValue: 1 << 1, value: "credit")
    /// Indicates a PIN debit account.
    /// - Description: Should be accompanied by track data and a PIN block.
    public static let debit     = PaymentMethodType(rawValue: 1 << 2, value: "debit")
    /// Indicates an EBT account.
    /// - Description: Should be accompanied by track data and a PIN block.
    public static let ebt       = PaymentMethodType(rawValue: 1 << 3)
    /// Indicates cash as the payment method.
    public static let cash      = PaymentMethodType(rawValue: 1 << 4)
    /// Indicates an ACH/eCheck account.
    /// - Description: Should be accompanied by a token or an account number and routing number.
    public static let ach       = PaymentMethodType(rawValue: 1 << 5)
    /// Indicates a gift/loyalty/stored value account.
    /// - Description: Should be accompanied by a token, card number, alias, or track data.
    public static let gift      = PaymentMethodType(rawValue: 1 << 6)
    /// Indicates a recurring payment method.
    /// - Description: Should be accompanied by a payment method key.
    public static let recurring = PaymentMethodType(rawValue: 1 << 7)

    public static let paypal    = PaymentMethodType(rawValue: 1 << 8)

    public static let apm       = PaymentMethodType(rawValue: 1 << 9)

    public static let BNPL      = PaymentMethodType(rawValue: 1 << 10)

    public static let bankPayment     = PaymentMethodType(rawValue: 1 << 11)

    public static let accountFunds     = PaymentMethodType(rawValue: 1 << 12)
}
