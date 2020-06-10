import Foundation

@objcMembers public class DecisionManager: NSObject {
    public var billToHostName: String?
    public var billToHttpBrowserCookiesAccepted: Bool?
    public var billToHttpBrowserEmail: String?
    public var billToHttpBrowserType: String?
    public var billToIpNetworkAddress: String?
    public var businessRulesCoreThreshold: String?
    public var billToPersonalId: String?
    public var decisionManagerProfile: String?
    public var invoiceHeaderTenderType: String?
    public var itemHostHedge: Risk?
    public var itemNonsensicalHedge: Risk?
    public var itemObscenitiesHedge: Risk?
    public var itemPhoneHedge: Risk?
    public var itemTimeHedge: Risk?
    public var itemVelocityHedge: Risk?
    public var invoiceHeaderIsGift: Bool?
    public var invoiceHeaderReturnsAccepted: Bool?

    public required override init() { }
}
