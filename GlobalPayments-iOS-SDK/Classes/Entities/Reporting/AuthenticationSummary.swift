import Foundation

/// Summary of an authentication (3DS) resource returned by the GET List Authentications
/// and GET Single Authentication reporting endpoints.
public class AuthenticationSummary {
    public var id: String?
    public var timeCreated: Date?
    public var status: String?
    public var merchantId: String?
    public var merchantName: String?
    public var accountId: String?
    public var accountName: String?
    public var channel: String?
    public var amount: NSDecimalNumber?
    public var currency: String?
    public var country: String?
    public var source: String?
    public var actionCreateId: String?
    public var systemMid: String?
    public var systemTid: String?
    public var systemName: String?

    // Payment method
    public var paymentMethodResult: String?
    public var paymentMethodMessage: String?
    public var paymentMethodEntryMode: String?
    public var paymentMethodFingerprint: String?
    public var paymentMethodFingerprintPresenceIndicator: String?
    public var paymentMethodName: String?

    // Card
    public var cardFunding: String?
    public var cardBrand: String?
    public var cardAuthCode: String?
    public var cardBrandReference: String?
    public var maskedCardNumber: String?
    public var cvvIndicator: String?
    public var cvvResult: String?
    public var avsAddressResult: String?
    public var avsPostalCodeResult: String?

    // Three DS
    public var acsTransactionId: String?
    public var acsReferenceNumber: String?
    public var directoryServerTransactionId: String?
    public var serverTransferReference: String?
    public var liabilityShift: String?
    public var authenticationValue: String?
    public var eci: String?
    public var threeDSecureStatus: String?
    public var threeDSecureStatusReason: String?
    public var messageCategory: String?
    public var messageVersion: String?
    public var challengeStatus: String?

    // Action
    public var action: ActionSummary?
}

