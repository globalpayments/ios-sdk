import Foundation

@objcMembers public class HostedPaymentConfig: NSObject {
    public var cardStorageEnabled: Bool?
    public var dynamicCurrencyConversionEnabled: Bool?
    public var displaySavedCards: Bool?
    public var fraudFilterMode: FraudFilterMode = .none
    public var language: String?
    public var paymentButtonText: String?
    public var postDimensions: String?
    public var postResponse: String?
    public var responseUrl: String?
    public var requestTransactionStabilityScore: Bool?
    public var version: HppVersion?

    public override required init() { }
}
