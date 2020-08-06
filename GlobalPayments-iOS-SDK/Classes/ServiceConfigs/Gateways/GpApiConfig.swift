import Foundation

public class GpApiConfig: GatewayConfig {
    /// GP API app id
    public let appId: String
    /// GP API app key
    public let appKey: String
    /// A unique random value included while creating the secret
    public var nonce: String
    /// The time left in seconds before the token expires
    public var secondsToExpire: Int?
    /// The time interval set for when the token will expire
    public var intervalToExpire: IntervalToExpire?
    /// Channel
    public var channel: Channel
    /// Language
    public var language: Language

    public init(appId: String,
                appKey: String,
                nonce: String = "transactionsapi",
                secondsToExpire: Int? = nil,
                intervalToExpire: IntervalToExpire? = nil,
                channel: Channel = .cardNotPresent,
                language: Language = .english) {

        self.appId = appId
        self.appKey = appKey
        self.nonce = nonce
        self.secondsToExpire = secondsToExpire
        self.intervalToExpire = intervalToExpire
        self.channel = channel
        self.language = language
        super.init(gatewayProvider: .gpAPI)
    }

    override func configureContainer(services: ConfiguredServices) {
        if serviceUrl.isNilOrEmpty {
            if environment == .test {
                serviceUrl = ServiceEndpoints.gpApiTest.rawValue
            } else {
                serviceUrl = ServiceEndpoints.gpApiProduction.rawValue
            }
        }

        let gateway = GpApiConnector()
        gateway.appId = appId
        gateway.appKey = appKey
        gateway.nonce = nonce
        gateway.secondsToExpire = secondsToExpire
        gateway.intervalToExpire = intervalToExpire
        gateway.channel = channel
        gateway.language = language
        gateway.serviceUrl = serviceUrl
        gateway.timeout = timeout

        services.gatewayConnector = gateway
        services.reportingService = gateway
    }
}
