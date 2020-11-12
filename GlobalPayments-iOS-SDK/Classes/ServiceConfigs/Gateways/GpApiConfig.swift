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
    /// Global API language configuration
    public var language: Language
    /// Two lettero ISO 3166 country
    public var country: String
    /// Access token information
    public var accessTokenInfo: AccessTokenInfo?

    public init(appId: String,
                appKey: String,
                nonce: String = "transactionsapi",
                secondsToExpire: Int? = nil,
                intervalToExpire: IntervalToExpire? = nil,
                channel: Channel = .cardNotPresent,
                language: Language = .english,
                country: String = "US",
                accessTokenInfo: AccessTokenInfo? = nil) {

        self.appId = appId
        self.appKey = appKey
        self.nonce = nonce
        self.secondsToExpire = secondsToExpire
        self.intervalToExpire = intervalToExpire
        self.channel = channel
        self.language = language
        self.country = country
        self.accessTokenInfo = accessTokenInfo
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
        gateway.secondsToExpire = secondsToExpire
        gateway.intervalToExpire = intervalToExpire
        gateway.channel = channel
        gateway.language = language
        gateway.country = country
        gateway.serviceUrl = serviceUrl
        gateway.timeout = timeout
        gateway.accessToken = accessTokenInfo?.token
        gateway.dataAccountName = accessTokenInfo?.dataAccountName
        gateway.disputeManagementAccountName = accessTokenInfo?.disputeManagementAccountName
        gateway.tokenizationAccountName = accessTokenInfo?.tokenizationAccountName
        gateway.transactionProcessingAccountName = accessTokenInfo?.transactionProcessingAccountName

        services.gatewayConnector = gateway
        services.reportingService = gateway
    }

    override func validate() throws {
        try super.validate()

        if accessTokenInfo == nil && (appId.isEmpty || appKey.isEmpty) {
            throw ConfigurationException(
                message: "accessTokenInfo or appId and appKey cannot be nil or empty"
            )
        }
    }
}
