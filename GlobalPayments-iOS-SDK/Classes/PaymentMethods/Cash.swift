import Foundation

/// Use cash as a payment method.
public class Cash: NSObject, PaymentMethod, Chargeable, Refundable {

    /// Set to `PaymentMethodType.cash` for internal methods.
    public var paymentMethodType: PaymentMethodType = .cash

    /// Sends a cash sale transaction to the gateway.
    ///
    /// This transaction is purely informational. No contact with the issuer
    /// or settlement will occur as the cash exchange will happen directly
    /// between the merchant and the consumer.
    ///
    /// - Parameter amount: The amount of the transaction
    /// - Returns: AuthorizationBuilder
    public func charge(amount: Decimal) -> AuthorizationBuilder {
        print("Aborts when the configured gateway does not support cash transactions.")
        abort()
    }

    /// Sends a cash refund transaction to the gateway.
    ///
    /// This transaction is purely informational. No contact with the issuer
    /// or settlement will occur as the cash exchange will happen directly
    /// between the merchant and the consumer.
    ///
    /// - Parameter amount: The amount of the transaction
    /// - Returns: AuthorizationBuilder
    public func refund(amount: Decimal) -> AuthorizationBuilder {
        print("Aborts when the configured gateway does not support cash transactions.")
        abort()
    }
}
