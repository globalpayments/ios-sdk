import Foundation

/// Data collection to supplement a hosted payment page.
@objcMembers public class HostedPaymentData {
    /// Indicates to the issuer that the shipping and billing addresses are expected to be the same.
    /// Used as a fraud prevention mechanism.
    public var addressesMatch: Bool?
    /// Determines the challenge request preference for 3DS 2.0.
    public var challengeRequest: ChallengeRequestIndicator?
    /// The customer's email address.
    public var customerEmail: String?
    /// Indicates if the customer is known and has an account.
    public var customerExists: Bool?
    /// The identifier for the customer.
    public var customerKey: String?
    /// The customer's number.
    public var customerNumber: String?
    /// The customer's mobile phone number.
    public var customerPhoneMobile: String?
    /// Indicates if the customer should be prompted to store their card.
    public var offerToSaveCard: Bool?
    /// The identifier for the customer's desired payment method.
    public var paymentKey: String?
    /// The product ID.
    public var productId: String?
    /// Supplementary data that can be supplied at the descretion of the merchant/application.
    public var supplementaryData: [String: String]

    public required init() {
        self.supplementaryData = [String: String]()
    }
}
