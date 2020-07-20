import Foundation

public class AlternatePaymentMethod: NSObject, PaymentMethod, Chargeable {
    /// Returns Payment Method Type.
    public var paymentMethodType: PaymentMethodType = .credit
    /// A  AlternativePaymentMethodType value representing the AlternativePaymentMethodType Name.
    public var alternativePaymentMethodType: AlternativePaymentMethodType?
    /// A returnUrl is representing after the payment where the transaction return to.
    public var returnUrl: String?
    /// A statusUpdateUrl is representing after the transaction where the status response will come like SUCCESS/PENDING
    public var statusUpdateUrl: String?
    /// A Descriptor value representing About Transaction.
    public var descriptor: String?
    /// A Country value representing the Country.
    public var country: String?
    public var accountHolderName: String?

    /// Creates a charge (sale) against the payment method.
    /// - Parameter amount: The amount of the transaction
    /// - Returns: AuthorizationBuilder
    public func charge(amount: Decimal? = nil) -> AuthorizationBuilder {
        return AuthorizationBuilder(transactionType: .sale, paymentMethod: self)
            .withAmount(amount)
    }
}
