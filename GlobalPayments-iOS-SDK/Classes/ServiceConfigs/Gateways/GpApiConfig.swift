import Foundation

public class GpApiConfig: GatewayConfig {
    /// GP API app id
    public let appId: String
    /// GP API app key
    public let appKey: String
    /// The time left in seconds before the token expires
    public var secondsToExpire: Int?
    /// The time interval set for when the token will expire
    public var intervalToExpire: IntervalToExpire?
    /// Channel
    public var channel: Channel
    /// Global API language configuration
    public var language: Language?
    /// Two letters ISO 3166 country
    public var country: String?
    /// Access token information
    public var accessTokenInfo: AccessTokenInfo?
    /// 3DSecure challenge return url
    public var challengeNotificationUrl: String?
    /// 3DSecure method return url
    public var methodNotificationUrl: String?
    /// URL of the merchant's website or customer care site.
    public var merchantContactUrl: String?
    /// The list of the permissions the integrator want the access token to have.
    public var permissions: [String]?

    public var dynamicHeaders: [String: String]?
    
    public var merchantId: String?

    public init(appId: String,
                appKey: String,
                secondsToExpire: Int? = nil,
                intervalToExpire: IntervalToExpire? = nil,
                channel: Channel = .cardNotPresent,
                language: Language? = .english,
                country: String? = "US",
                accessTokenInfo: AccessTokenInfo? = nil,
                challengeNotificationUrl: String? = nil,
                methodNotificationUrl: String? = nil,
                merchantContactUrl: String? = nil,
                permissions: [String]? = nil,
                dynamicHeaders: [String: String]? = nil,
                merchantId: String? = nil) {

        self.appId = appId
        self.appKey = appKey
        self.secondsToExpire = secondsToExpire
        self.intervalToExpire = intervalToExpire
        self.channel = channel
        self.language = language
        self.country = country
        self.accessTokenInfo = accessTokenInfo
        self.challengeNotificationUrl = challengeNotificationUrl
        self.methodNotificationUrl = methodNotificationUrl
        self.permissions = permissions
        self.merchantContactUrl = merchantContactUrl
        self.dynamicHeaders = dynamicHeaders
        self.merchantId = merchantId
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

        let gateway = GpApiConnector(gpApiConfig: self)
        gateway.serviceUrl = serviceUrl
        gateway.timeout = timeout
        gateway.accessToken = accessTokenInfo?.token

        services.gatewayConnector = gateway
        services.reportingService = gateway
        services.setSecure3dProvider(provider: gateway, version: .one)
        services.setSecure3dProvider(provider: gateway, version: .two)
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
