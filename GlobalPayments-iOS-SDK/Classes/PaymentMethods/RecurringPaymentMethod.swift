import Foundation

public class RecurringPaymentMethod: RecurringEntity<RecurringPaymentMethod>, PaymentMethod, Chargeable, Authable, Verifiable, Refundable, Secure3d {

    public var paymentMethodType: PaymentMethodType = .recurring
    public var threeDSecure: ThreeDSecure?
    /// The address associated with the payment method account.
    public var address: Address?
    /// The payment method's commercial indicator (Level II/III).
    public var commercialIndicator: String?
    /// The identifier of the payment method's customer.
    public var customerKey: String?
    /// The payment method's expiration date.
    public var expirationDate: String?
    /// The name on the payment method account.
    public var nameOnAccount: String?
    private var paymentMethod: PaymentMethod?
    /// The payment method type, `Credit Card` vs `ACH`.
    /// Default value is `Credit Card`
    public var paymentType: String = "Credit Card"
    /// Indicates if the payment method is the default/preferred
    public var preferredPayment: Bool?
    /// The payment method status
    public var status: String?
    /// The payment method's tax type
    public var taxType: String?

    public required init(paymentId: String? = nil,
                         customerId: String? = nil,
                         paymentMethod: PaymentMethod? = nil) {
        super.init()

        if paymentMethod != nil {
            self.paymentMethod = paymentMethod
            return
        }

        self.customerKey = customerId
        self.key = paymentId
    }

    /// Creates an authorization against the payment method.
    /// - Parameter amount: The amount of the transaction
    /// - Returns: AuthorizationBuilder
    public func authorize(amount: NSDecimalNumber = .zero,
                          isEstimated: Bool = false) -> AuthorizationBuilder {
        return AuthorizationBuilder(transactionType: .auth, paymentMethod: self)
            .withAmount(amount)
            .withOneTimePayment(true)
            .withAmountEstimated(isEstimated)
    }

    /// Creates a charge (sale) against the payment method.
    /// - Parameter amount: The amount of the transaction
    /// - Returns: AuthorizationBuilder
    public func charge(amount: NSDecimalNumber? = nil) -> AuthorizationBuilder {
        return AuthorizationBuilder(transactionType: .sale, paymentMethod: self)
            .withAmount(amount)
            .withOneTimePayment(true)
    }

    /// Refunds the payment method.
    /// - Parameter amount: The amount of the transaction
    /// - Returns: AuthorizationBuilder
    public func refund(amount: NSDecimalNumber? = nil) -> AuthorizationBuilder {
        return AuthorizationBuilder(transactionType: .refund, paymentMethod: self)
            .withAmount(amount)
    }
    
    /// Verifies the payment method with the issuer.
    /// - Returns: AuthorizationBuilder
    public func verify() -> AuthorizationBuilder {
        return AuthorizationBuilder(transactionType: .verify, paymentMethod: self)
    }

    /// Creates a recurring schedule using the payment method.
    /// - Parameter scheduleId: The schedule's identifier
    /// - Returns: Schedule
    public func addSchedule(scheduleId: String? = nil) -> Schedule {
        let schedule = Schedule(customerKey: self.customerKey, paymentKey: self.key)
        schedule.id = scheduleId
        return schedule
    }
}
