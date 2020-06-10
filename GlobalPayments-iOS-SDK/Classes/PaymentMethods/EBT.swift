import Foundation

/// Use EBT as a payment method.
@objcMembers public class EBT: NSObject, PaymentMethod, Balanceable, Chargeable, Refundable, PinProtected {

    public var pinBlock: String?
    /// Set to `PaymentMethodType.ebt` for internal methods.
    public var paymentMethodType: PaymentMethodType = .ebt

    public func balanceInquiry(inquiry: InquiryType = .foodstamp) -> AuthorizationBuilder {
        return AuthorizationBuilder(transactionType: .balance, paymentMethod: self)
            .withBalanceInquiryType(inquiry)
            .withAmount(.zero)
    }

    public func benefitWithdrawal(amount: Decimal?) -> AuthorizationBuilder {
        return AuthorizationBuilder(transactionType: .benefitWithdrawal, paymentMethod: self)
            .withAmount(.zero)
            .withCashBack(.zero)
    }

    public func charge(amount: Decimal) -> AuthorizationBuilder {
        return AuthorizationBuilder(transactionType: .sale, paymentMethod: self)
            .withAmount(.zero)
    }
    
    public func refund(amount: Decimal) -> AuthorizationBuilder {
        return AuthorizationBuilder(transactionType: .refund, paymentMethod: self)
            .withAmount(.zero)
    }
}
