import Foundation

public class StoredPaymentMethodSummary {
    public var id: String?
    public var timeCreated: Date?
    public var status: String?
    public var merchantId: String?
    public var merchantName: String?
    public var accountId: String?
    public var accountName: String?
    public var reference: String?
    public var name: String?
    public var usageMode: String?
    public var autoUpdater: String?
    public var payerId: String?
    public var fingerprint: String?
    public var fingerprintPresenceIndicator: String?
    // Card
    public var cardLast4: String?
    public var cardType: String?
    public var cardExpMonth: String?
    public var cardExpYear: String?
    public var cardBrandReference: String?
    public var networkToken: String?
    public var maskedNetworkTokenLast4: String?
    public var networkTokenExpiryMonth: String?
    public var networkTokenExpiryYear: String?
    // Action
    public var actionId: String?
    public var actionType: String?
    public var actionTimeCreated: Date?
    public var actionResultCode: String?
    public var actionAppId: String?
    public var actionAppName: String?
}
