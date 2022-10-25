import Foundation


public class CardIssuerResponse {
    
    // The result code of the AVS check from the card issuer.
    public var avsResult: String?
    
    // Result code from the card issuer.
    public var result: String?
    
    // The result code of the CVV check from the card issuer.
    public var cvvResult: String?
    
    // The result code of the AVS address check from the card issuer.
    public var avsAddressResult: String?
    
    // The result of the AVS postal code check from the card issuer.
    public var avsPostalCodeResult: String?
    
}
