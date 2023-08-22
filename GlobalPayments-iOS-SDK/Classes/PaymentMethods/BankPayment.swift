import Foundation

public class BankPayment: NSObject, PaymentMethod, Chargeable, NotificationData {

    /// Merchant/Individual Name.
    public var accountName: String?
    ///  Financial institution account number.
    public var accountNumber: String?
    /// A  SORT   Code   is a number code, which is used by British and Irish banks.
    /// These codes have six digits, and they are divided into three different pairs, such as 12-34-56.
    public var sortCode: String?
    /// The International Bank Account Number
    public var iban: String?
    
    public var paymentMethodType: PaymentMethodType = .bankPayment
    public var returnUrl: String?
    public var statusUpdateUrl: String?
    public var cancelUrl: String?
    
    public var bankPaymentType: BankPaymentType?

    public var countries: [String]?
    
    
    public func charge(amount: NSDecimalNumber?) -> AuthorizationBuilder {
        return AuthorizationBuilder(transactionType: .sale, paymentMethod: self)
            .withModifier(.bankPayment)
            .withAmount(amount)
    }
}
