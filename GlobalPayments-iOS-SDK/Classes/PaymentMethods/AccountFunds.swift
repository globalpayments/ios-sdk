import Foundation

public class AccountFunds: NSObject, PaymentMethod {

    public var paymentMethodType: PaymentMethodType = .accountFunds
    public var accountId: String?
    public var accountName: String?
    public var merchantId: String?
    public var recipientAccountId: String?
    public var usableBalanceMode: UsableBalanceMode?
    
    
    public func transfer(amount: NSDecimalNumber? = nil) -> AuthorizationBuilder {
        return  AuthorizationBuilder(transactionType: .transferFunds, paymentMethod: self)
            .withAmount(amount)
    }
}
