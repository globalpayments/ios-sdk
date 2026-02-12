import Foundation

public class PayerDetails: NSObject {
    
    public var firstName: String?
    public var lastName: String?
    public var email: String?
    public var name : String?
    public var country: String?
    public var landlinePhone: String?
    public var mobilePhone: String?
    public var taxIdReference: String?
    public var billingAddress: Address?
    public var shippingAddress: Address?
}
