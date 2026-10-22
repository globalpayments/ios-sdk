import Foundation

/// Request data for editing a merchant's account configuration via `PATCH /accounts/{id}`.
public class AccountEditData {
    /// First and last name on the payout payment method
    public var payerPaymentMethodName: String?
    /// A label that further describes the payout payment method
    public var payerPaymentMethodReference: String?
    public var card: CreditCardData?
    public var billingAddress: Address?
    public var cardReplacementReason: CardReplacementReason?
    public var capabilities: [AccountCapability]?
    public var processingLimits: AccountProcessingLimits?
    public var statusChangeReason: StatusChangeReason?
    /// URL Global Payments will post account status change notifications to.
    public var notificationStatusUrl: String?

    public init() {}
}
