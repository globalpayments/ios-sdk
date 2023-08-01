import Foundation

public class BNPLResponse: NSObject {
    
    public var providerName: String?
    /// URL to redirect the customer, sent so merchant can redirect consumer to complete the payment.
    public var redirectUrl: String?
}
