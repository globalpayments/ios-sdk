import Foundation

public protocol NotificationData {
    /// The endpoint to which the customer should be redirected after a payment has been attempted or
    /// successfully completed on the payment scheme's site.
    var returnUrl: String? { get set }
    /// The endpoint which will receive payment-status messages.
    /// This will include the result of the transaction or any updates to the transaction status.
    /// For certain asynchronous payment methods these notifications may come hours or
    /// days after the initial authorization.
    var statusUpdateUrl: String? { get set }
    /// The customer will be redirected back to your notifications.cancel_url in case the transaction is canceled
    var cancelUrl: String? { get set }
}
