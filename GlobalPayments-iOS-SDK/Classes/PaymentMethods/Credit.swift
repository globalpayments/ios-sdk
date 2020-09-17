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
    public func authorize(amount: NSDecimalNumber? = nil,
                          isEstimated: Bool = false) -> AuthorizationBuilder {
        return AuthorizationBuilder(transactionType: .auth, paymentMethod: self)
            .withAmount(amount ?? threeDSecure?.amount)
            .withCurrency(threeDSecure?.currency)
            .withOrderId(threeDSecure?.orderId)
            .withAmountEstimated(isEstimated)
    }

    /// Creates a charge (sale) against the payment method.
    /// - Parameter amount: The amount of the transaction
    /// - Returns: AuthorizationBuilder
    public func charge(amount: NSDecimalNumber? = nil) -> AuthorizationBuilder {
        return AuthorizationBuilder(transactionType: .sale, paymentMethod: self)
            .withAmount(amount)
            .withCurrency(threeDSecure?.currency)
            .withOrderId(threeDSecure?.orderId)
    }

    /// Adds value to to a payment method.
    /// - Parameter amount: The amount of the transaction
    /// - Returns: AuthorizationBuilder
    public func addValue(amount: NSDecimalNumber? = nil) -> AuthorizationBuilder {
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
    public func refund(amount: NSDecimalNumber? = nil) -> AuthorizationBuilder {
        return AuthorizationBuilder(transactionType: .refund, paymentMethod: self)
            .withAmount(amount)
    }

    /// Reverses a previous transaction against the payment method.
    /// - Parameter amount: The amount of the transaction
    /// - Returns: AuthorizationBuilder
    public func reverse(amount: NSDecimalNumber?) -> AuthorizationBuilder {
        return AuthorizationBuilder(transactionType: .reversal, paymentMethod: self)
            .withAmount(amount)
    }

    /// Verifies the payment method with the issuer.
    /// - Returns: AuthorizationBuilder
    public func verify() -> AuthorizationBuilder {
        return AuthorizationBuilder(transactionType: .verify, paymentMethod: self)
    }

    public func tokenize(configName: String = "default",
                         completion: ((String?, Error?) -> Void)?) {

        tokenize(validateCard: true, configName: configName, completion: completion)
    }

    public func tokenize(validateCard: Bool,
                         configName: String = "default",
                         completion: ((String?, Error?) -> Void)?) {

        let type: TransactionType = validateCard ? .verify : .tokenize
        AuthorizationBuilder(transactionType: type, paymentMethod: self)
            .withRequestMultiUseToken(true)
            .execute(configName: configName, completion: { transaction, error in
                completion?(transaction?.token, error)
            })
    }

    /// Updates the token expiry date with the values proced to the card object
    /// - Throws: BuilderException
    /// - Returns: boolean value indicating success/failure
    public func updateTokenExpiry(
        configName: String = "default",
        completion: ((Bool, Error?) -> Void)?) {

        if token.isNilOrEmpty {
            completion?(false, BuilderException(message: "Token cannot be null"))
            return
        }
        ManagementBuilder(transactionType: .tokenUpdate)
            .withPaymentMethod(self)
            .execute(configName: configName, completion: { transaction, error in
                if let error = error {
                    completion?(false, error)
                    return
                }
                completion?(transaction != nil, nil)
            })
    }

    /// Deletes the token associated with the current card object
    /// - Throws: BuilderException
    /// - Returns: boolean value indicating success/failure
    public func deleteToken(
        configName: String = "default",
        completion: ((Bool, Error?) -> Void)?) {

        if token.isNilOrEmpty {
            completion?(false, BuilderException(message: "Token cannot be null"))
            return
        }
        ManagementBuilder(transactionType: .tokenDelete)
            .withPaymentMethod(self)
            .execute(configName: configName, completion: { transaction, error in
                if let error = error {
                    completion?(false, error)
                    return
                }
                completion?(transaction != nil, nil)
            })
    }
}
