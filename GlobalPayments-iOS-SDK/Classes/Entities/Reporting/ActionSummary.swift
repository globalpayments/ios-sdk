import Foundation

public class ActionSummary {
    public var id: String?
    public var type: String?
    public var timeCreated: Date?
    public var resource: String?
    public var version: String?
    public var resourceId: String?
    public var resourceStatus: String?
    public var httpResponseCode: String?
    public var responseCode: String?
    public var appId: String?
    public var appName: String?
    public var accountId: String?
    public var accountName: String?
    public var merchantName: String?
    public var resultCode: String?
    // The following are only populated by the GET /actions/{id} single-detail response.
    public var merchantId: String?
    public var resourceParentId: String?
    public var resourceRequestUrl: String?
    public var responseDetailedCode: String?
    public var responseDetailedMessage: String?
    public var email: String?
    public var sourceLocation: String?
    public var destinationLocation: String?
    public var messageReceived: String?
    public var messageSent: String?
    public var metrics: String?
    public var totalTimeMilliseconds: String?
    public var totalTimeDownstreamMilliseconds: String?
}
