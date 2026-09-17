import Foundation

public class BNPLResponse: NSObject {
    
    public var providerName: String?
    /// URL to redirect the customer, sent so merchant can redirect consumer to complete the payment.
    public var redirectUrl: String?
    /// Result code returned by the BNPL provider (e.g. "201 CREATED").
    public var result: String?
}
