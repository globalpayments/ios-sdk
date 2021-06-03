import Foundation

/// Use PIN debit as a payment method.
public class Debit: NSObject, PaymentMethod, PrePaid, Refundable, Reversable, Chargeable, Encryptable, PinProtected {

    public var cardType: String = "Unknown"
    /// Set to `PaymentMethodType.debit` for internal methods.
    public var paymentMethodType: PaymentMethodType = .debit
    public var encryptionData: EncryptionData?
    public var pinBlock: String?

    public func addValue(amount: NSDecimalNumber? = nil) -> AuthorizationBuilder {
        return AuthorizationBuilder(transactionType: .addValue, paymentMethod: self)
            .withAmount(amount)
    }

    public func charge(amount: NSDecimalNumber? = nil) -> AuthorizationBuilder {
        return AuthorizationBuilder(transactionType: .sale, paymentMethod: self)
            .withAmount(amount)
    }

    public func refund(amount: NSDecimalNumber? = nil) -> AuthorizationBuilder {
        return AuthorizationBuilder(transactionType: .refund, paymentMethod: self)
            .withAmount(amount)
    }

    public func reverse(amount: NSDecimalNumber? = nil) -> AuthorizationBuilder {
        return AuthorizationBuilder(transactionType: .reversal, paymentMethod: self)
            .withAmount(amount)
    }

    public func authorize(amount: NSDecimalNumber? = nil, isEstimated: Bool = true) -> AuthorizationBuilder {
        return AuthorizationBuilder(transactionType: .auth, paymentMethod: self)
            .withAmount(amount)
            .withAmountEstimated(isEstimated)
    }
}
