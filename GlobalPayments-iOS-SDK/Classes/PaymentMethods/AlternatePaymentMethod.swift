import Foundation

public class AlternatePaymentMethod: NSObject, PaymentMethod, Chargeable, NotificationData {
    
    /// Returns Payment Method Type.
    public var paymentMethodType: PaymentMethodType = .credit
    /// A  AlternativePaymentMethodType value representing the AlternativePaymentMethodType Name.
    public var alternativePaymentMethodType: AlternativePaymentMethodType?
    /// A Descriptor value representing About Transaction.
    public var descriptor: String?
    /// A Country value representing the Country.
    public var country: String?
    public var accountHolderName: String?
    /// Accepted values ENABLE/DISABLE
    public var addressOverrideMode: String?
    public var returnUrl: String?
    public var statusUpdateUrl: String?
    public var cancelUrl: String?

    /// Creates a charge (sale) against the payment method.
    /// - Parameter amount: The amount of the transaction
    /// - Returns: AuthorizationBuilder
    public func charge(amount: NSDecimalNumber? = nil) -> AuthorizationBuilder {
        return AuthorizationBuilder(transactionType: .sale, paymentMethod: self)
            .withAmount(amount)
    }
    
    /// Authorizes the payment method
    /// - Parameter amount: The amount of the transaction
    /// - Returns: AuthorizationBuilder
    public func authorize(amount: NSDecimalNumber? = nil) -> AuthorizationBuilder{
        return AuthorizationBuilder(transactionType: .auth, paymentMethod: self)
            .withModifier(.alternativePaymentMethod)
            .withAmount(amount)
    }
}
