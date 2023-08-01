import Foundation

public class BNPL: NSObject, PaymentMethod, Authable, NotificationData {

    public var paymentMethodType: PaymentMethodType = .BPNL
    public var BNPLType: BNPLType?
    public var returnUrl: String?
    public var statusUpdateUrl: String?
    public var cancelUrl: String?
    
    public func authorize(amount: NSDecimalNumber?, isEstimated: Bool = false) -> AuthorizationBuilder {
        return AuthorizationBuilder(transactionType: .auth, paymentMethod: self)
            .withModifier(.buyNowPayLater)
            .withAmount(amount)
    }
}
