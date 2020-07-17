import Foundation

/// Use credit as a payment method.
public class Credit: NSObject, PaymentMethod, Encryptable, Tokenizable, Chargeable, Authable, Refundable, Reversable, Verifiable, PrePaid, Balanceable, Secure3d {
    /// Set to `PaymentMethodType.credit` for internal methods.
    public var paymentMethodType: PaymentMethodType = .credit
    /// The card's encryption data; where applicable.
    public var encryptionData: EncryptionData?
    /// A token value representing the card.
    public var token: String?
    /// Secure 3d Data attached to the card
    public var threeDSecure: ThreeDSecure?
    /// The card type of the manual entry data.
    /// Default value is `"Unknown"`.
    public var cardType: String? = "Unknown"
    /// A MobileType value representing the Google/Apple.
    public var mobileType: String?
    public var fleetCard: Bool?

    public required override init() { }

    /// Creates an authorization against the payment method.
    /// - Parameters:
    ///   - amount: The amount of the transaction
    /// - Returns: AuthorizationBuilder
    public func authorize(amount: Decimal = .zero,
                          isEstimated: Bool = false) -> AuthorizationBuilder {
        return AuthorizationBuilder(transactionType: .auth, paymentMethod: self)
            .withAmount(amount)
            .withCurrency(threeDSecure?.currency)
            .withOrderId(threeDSecure?.orderId)
            .withAmountEstimated(isEstimated)
    }

    /// Creates a charge (sale) against the payment method.
    /// - Parameter amount: The amount of the transaction
    /// - Returns: AuthorizationBuilder
    public func charge(amount: Decimal = .zero) -> AuthorizationBuilder {
        return AuthorizationBuilder(transactionType: .sale, paymentMethod: self)
            .withAmount(amount)
            .withCurrency(threeDSecure?.currency)
            .withOrderId(threeDSecure?.orderId)
    }

    /// Adds value to to a payment method.
    /// - Parameter amount: The amount of the transaction
    /// - Returns: AuthorizationBuilder
    public func addValue(amount: Decimal = .zero) -> AuthorizationBuilder {
        return AuthorizationBuilder(transactionType: .addValue, paymentMethod: self)
            .withAmount(amount)
    }

    /// Completes a balance inquiry (lookup) on the payment method.
    /// - Parameter inquiry: The type of inquiry to make
    /// - Returns: AuthorizationBuilder
    public func balanceInquiry(inquiry: InquiryType) -> AuthorizationBuilder {
        return AuthorizationBuilder(transactionType: .balance, paymentMethod: self)
            .withBalanceInquiryType(inquiry)
    }

    /// Refunds the payment method.
    /// - Parameter amount: The amount of the transaction
    /// - Returns: AuthorizationBuilder
    public func refund(amount: Decimal = .zero) -> AuthorizationBuilder {
        return AuthorizationBuilder(transactionType: .refund, paymentMethod: self)
            .withAmount(amount)
    }

    /// Reverses a previous transaction against the payment method.
    /// - Parameter amount: The amount of the transaction
    /// - Returns: AuthorizationBuilder
    public func reverse(amount: Decimal) -> AuthorizationBuilder {
        return AuthorizationBuilder(transactionType: .reversal, paymentMethod: self)
            .withAmount(amount)
    }

    /// Verifies the payment method with the issuer.
    /// - Returns: AuthorizationBuilder
    public func verify() -> AuthorizationBuilder {
        return AuthorizationBuilder(transactionType: .verify, paymentMethod: self)
    }

    public func tokenize(completion: ((String?) -> Void)?) {
        AuthorizationBuilder(transactionType: .verify, paymentMethod: self)
            .withRequestMultiUseToken(true)
            .execute { transaction in
                completion?(transaction?.token)
        }
    }

    /// Updates the token expiry date with the values proced to the card object
    /// - Throws: BuilderException
    /// - Returns: boolean value indicating success/failure
    public func updateTokenExpiry(completion: ((Bool) -> Void)?) throws {
        if token.isNilOrEmpty {
            throw BuilderException.generic(message: "Token cannot be null")
        }
        ManagementBuilder(transactionType: .tokenUpdate)
            .withPaymentMethod(self)
            .execute { transaction in
                completion?(transaction != nil)
        }
    }

    /// Deletes the token associated with the current card object
    /// - Throws: BuilderException
    /// - Returns: boolean value indicating success/failure
    public func deleteToken(completion: ((Bool) -> Void)?) throws {
        if token.isNilOrEmpty {
            throw BuilderException.generic(message: "Token cannot be null")
        }
        ManagementBuilder(transactionType: .tokenDelete)
            .withPaymentMethod(self)
            .execute { transaction in
                completion?(transaction != nil)
        }
    }
}
