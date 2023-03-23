import Foundation

public class BankAccountData: NSObject {
    /// ISO 3166 standard 3-character country code
    public var accountCountryCode: String?
    /// Merchant/Individual Name
    public var accountName: String?
    /// Financial Institution account number
    public var accountNumber: String?
    /// Valid values are: Personal and Business
    public var accountOwnershipType: String?
    /// Valid Values are:
    /// C - Checking
    /// S - Savings
    /// G - General Ledger
    public var accountType: String?
    /// Name of financial institution
    public var bankName: String?
    /// Financial institution routing number. Must be a valid ACH routing number.
    public var routingNumber: String?
    /// The account holder's name. This is required if payment method is a bank account.
    public var accountHolderName: String?
    
    public var bankAddress: Address?
}
