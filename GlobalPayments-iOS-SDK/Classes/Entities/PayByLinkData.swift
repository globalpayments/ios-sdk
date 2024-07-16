import Foundation

public class PayByLinkData: NSObject {
    
    /// Describes the type of link that will be created.
    public var type: PayByLinkType?
    /// Indicates whether the link can be used once or multiple times
    public var usageMode: PaymentMethodUsageMode?

    public var allowedPaymentMethods: [PaymentMethodName]?
    /// The number of the times that the link can be used or paid.
    public var usageLimit: String?

    public var status: PayByLinkStatus?
    /// A descriptive name for the link. This will be visible to the customer on the payment page.
    public var name: String?
    /// Indicates if you want to capture the customers shipping information on the hosted payment page.
    /// If you enable this field you can also set an optional shipping fee in the shipping_amount.
    public var isShippable: Bool?
    /// Indicates the cost of shipping when the shippable field is set to YES.
    public var shippingAmount: NSDecimalNumber?
    /// Indicates the date and time after which the link can no longer be used or paid.
    public var expirationDate: Date?
    /// Images that will be displayed to the customer on the payment page.
    public var images: [String]?
    /// The merchant URL that the customer will be redirected to.
    public var returnUrl: String?
    /// The merchant URL (webhook) to notify the merchant of the latest status of the transaction
    public var statusUpdateUrl: String?
    /// The merchant URL that the customer will be redirected to if they chose to cancel
    public var cancelUrl: String?
}
