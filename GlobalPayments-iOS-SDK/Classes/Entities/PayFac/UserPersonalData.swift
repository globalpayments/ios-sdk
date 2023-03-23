import Foundation

public class UserPersonalData: NSObject {
    /// Merchant/Individual first name
    public var firstName: String?
    /// Merchant/Individual middle initial
    public var middleInitial: String?
    /// Merchant/Individual lane name
    public var lastName: String?
    /// Merchant/Individual first name
    public var userName: String?
    /// Merchant/Individual date of birth. Must be in 'mm-dd-yyyy' format. Individual must be 18+ to obtain an account. The value 01-01-1981 will give a successul response. All others will return a Status 66 (Failed KYC).
    public var dateOfBirth: String?
    /// Merchant/Individual social security number. Must be 9 characters without dashes. Required for USA when using personal validation. If business validated, do not pass!
    public var SSN: String?
    /// Merchant/Individual email address. Must be unique in ProPay system. ProPay's system will send automated emails to the email address on file unless NotificationEmail is provided. This value is truncated beyond 55 characters.
    public var sourceEmail: String?
    /// Merchant/Individual day phone number. For USA, CAN, NZL, and AUS value must be 10 characters
    public var dayPhone: String?
    /// Merchant/Individual evening phone number. For USA, CAN, NZL, and AUS value must be 10 characters
    public var eveningPhone: String?
    /// Communication email address. ProPay's system will send automated emails to the email address on file rather than the source email
    public var notificationEmail: String?
    /// Required to specify the currency in which funds should be held, if other than USD. An affiliation must be granted permission to create accounts in currencies other than USD. ISO 4217 standard 3 character currency code.
    public var currencyCode: String?
    /// One of the previously assigned merchant tiers. If not provided, will default to cheapest available tier.
    public var tier: String?
    /// This is a partner's own unique identifier. Typically used as the distributor or consultant ID
    public var externalID: String?
    ///  Numeric value which will give a user access to ProPay's IVR system. Can also be used to reset password
    public var phonePIN: String?
    /// ProPay account username. Must be unique in ProPay system. Username defaults to <sourceEmail> if userId is not provided
    public var userID: String?
    /// Merchant/Individual address
    public var userAddress: Address?
    /// Business physical address
    public var mailingAddress: Address?
    /// The legal business name of the merchant being boarded.
    public var legalName: String?
    /// The merchant's DBA (Doing Business As) name or the alternate name the merchant may be known as.
    public var DBA: String?
    /// A four-digit number used to classify the merchant into an industry or market segment.
    public var merchantCategoryCode: Int?
    /// The merchant's business website URL
    public var website: String?

    public var type: UserType?

    public var notificationStatusUrl: String?
    /// The merchants tax identification number. For example, in the US the (EIN) Employer Identification Number would be used.
    public var taxIdReference: String?
}
