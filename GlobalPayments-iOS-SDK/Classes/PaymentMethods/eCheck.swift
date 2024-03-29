import Foundation

/// Use eCheck/ACH as a payment method.
public class eCheck: NSObject, PaymentMethod, Chargeable, Refundable {

    /// Set to `PaymentMethodType.ach` for internal methods.
    public var paymentMethodType: PaymentMethodType = .ach
    public var accountNumber: String?
    public var accountType: AccountType?
    public var achVerify: Bool?
    public var birthYear: Int?
    public var checkHolderName: String?
    public var checkName: String?
    public var checkNumber: String?
    public var checkType: CheckType?
    public var checkVerify: Bool?
    public var driversLicenseNumber: String?
    public var driversLicenseState: String?
    public var entryMode: EntryMethod?
    public var micrNumber: String?
    public var phoneNumber: String?
    public var routingNumber: String?
    public var secCode: String?
    public var ssnLast4: String?
    public var token: String?
    public var checkReference: String?
    public var merchantNotes: String?
    public var bankName: String?
    public var bankAddress: Address?

    public func charge(amount: NSDecimalNumber? = nil) -> AuthorizationBuilder {
        return AuthorizationBuilder(transactionType: .sale, paymentMethod: self)
            .withAmount(amount)
    }

    public func refund(amount: NSDecimalNumber?) -> AuthorizationBuilder {
        return AuthorizationBuilder(transactionType: .refund, paymentMethod: self)
            .withAmount(amount)
    }
}
