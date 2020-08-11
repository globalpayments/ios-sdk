import Foundation

/// Use EBT as a payment method.
public class EBT: NSObject, PaymentMethod, Balanceable, Chargeable, Refundable, PinProtected {

    public var pinBlock: String?
    /// Set to `PaymentMethodType.ebt` for internal methods.
    public var paymentMethodType: PaymentMethodType = .ebt

    public func balanceInquiry(inquiry: InquiryType = .foodstamp) -> AuthorizationBuilder {
        return AuthorizationBuilder(transactionType: .balance, paymentMethod: self)
            .withBalanceInquiryType(inquiry)
            .withAmount(.zero)
    }

    public func benefitWithdrawal(amount: NSDecimalNumber?) -> AuthorizationBuilder {
        return AuthorizationBuilder(transactionType: .benefitWithdrawal, paymentMethod: self)
            .withAmount(amount)
            .withCashBack(.zero)
    }

    public func charge(amount: NSDecimalNumber? = nil) -> AuthorizationBuilder {
        return AuthorizationBuilder(transactionType: .sale, paymentMethod: self)
            .withAmount(amount)
    }
    
    public func refund(amount: NSDecimalNumber? = nil) -> AuthorizationBuilder {
        return AuthorizationBuilder(transactionType: .refund, paymentMethod: self)
            .withAmount(amount)
    }
}
