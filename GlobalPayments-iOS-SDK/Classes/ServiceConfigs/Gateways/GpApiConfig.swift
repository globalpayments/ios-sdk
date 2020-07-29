import Foundation

public class GpApiConfig: GatewayConfig {
    /// GP API app id
    public var appId: String?
    /// GP API app key
    public var appKey: String?
    /// A unique random value included while creating the secret
    public var nonce: String = "transactionsapi"
    /// The time left in seconds before the token expires
    public var secondsToExpire: Int?
    /// The time interval set for when the token will expire
    public var intervalToExpire: IntervalToExpire?
    /// Channel
    public var channel: Channel = .cardNotPresent
    /// Language
    public var language: Language = .english

    public init() {
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

//        let gateway = GpApiConfig
    }
}

//
//
//    internal override void ConfigureContainer(ConfiguredServices services) {
//        var gateway = new GpApiConnector {
//            AppId = AppId,
//            AppKey = AppKey,
//            Nonce = Nonce,
//            SecondsToExpire = SecondsToExpire,
//            IntervalToExpire = IntervalToExpire,
//            Channel = Channel,
//            Language = Language,
//            ServiceUrl = ServiceUrl,
//            Timeout = Timeout
//        };
//
//        services.GatewayConnector = gateway;
//
//        services.ReportingService = gateway;
//    }
//
//    internal override void Validate() {
//        base.Validate();
//
//        if (AppId == null || AppKey == null)
//            throw new ConfigurationException("AppId and AppKey cannot be null.");
//    }
//}
