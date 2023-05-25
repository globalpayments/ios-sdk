import Foundation


public class Card: NSObject {
    
    public var cardHolderName: String?
    public var cardNumber: String?
    public var maskedCardNumber: String?
    public var cardExpMonth: Int?
    public var cardExpYear: Int?
    public var token: String?
    
    /// Masked card number with last 4 digits showing.
    public var maskedNumberLast4: String?
    /// Indicates the card brand that issued the card.
    public var brand: String?
    /// The unique reference created by the brands/schemes to uniquely identify the transaction.
    public var brandReference: String?
    /// Contains the fist 6 digits of the card
    public var bin: String?
    /// The issuing country that the bin is associated with.
    public var binCountry: String?
    /// The card providers description of their card product.
    public var accountType: String?
    /// The label of the issuing bank or financial institution of the bin.
    public var issuer: String?
}
