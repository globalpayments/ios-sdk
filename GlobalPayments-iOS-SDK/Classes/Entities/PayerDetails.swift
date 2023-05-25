import Foundation

public class PayerDetails: NSObject {
    
    public var firstName: String?
    public var lastName: String?
    public var email: String?
    public var billingAddress: Address?
    public var shippingAddress: Address?
}
