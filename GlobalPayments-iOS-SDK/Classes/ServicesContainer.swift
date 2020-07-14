import Foundation

/// Maintains references to the currently configured gateway/device objects
/// The public `ServicesContainer.configure` method is the only call
/// required of the integrator to configure the SDK's various gateway/device
/// interactions. The configured gateway/device objects are handled
/// internally by exposed APIs throughout the SDK.

public class ServicesContainer: NSObject {

    public static let shared = ServicesContainer()

    private var secure3dProviders: [Secure3dVersion: Secure3dProvider]
    public var gateway: PaymentGateway?
    public var recurring: IRecurringService?
    var reportingService: ReportingService?

    public required init(gateway: PaymentGateway? = nil) {
        self.gateway = gateway
        self.secure3dProviders = [Secure3dVersion: Secure3dProvider]()
    }

    public func secure3dProvider(_ version: Secure3dVersion) -> Secure3dProvider? {
        if secure3dProviders.keys.contains(version) {
            return secure3dProviders[version]
        } else if version == .any {
            var provider = secure3dProviders[.two]
            if provider == nil {
                provider = secure3dProviders[.one]
            }
            return provider
        }

        return nil
    }

    public func configure(config: ServiceConfig) throws {
        try config.validate()
        gateway = nil
        if !config.merchantId.isNilOrEmpty {
            if config.serviceUrl.isNilOrEmpty {
                if config.environment == .test {
                    config.serviceUrl = ServiceEndpoints.globalEcomTest.rawValue
                } else {
                    config.serviceUrl = ServiceEndpoints.globalEcomProduction.rawValue
                }
            }
//            $gateway = new RealexConnector();
//            $gateway->accountId = $config->accountId;
//            $gateway->channel = $config->channel;
//            $gateway->merchantId = $config->merchantId;
//            $gateway->rebatePassword = $config->rebatePassword;
//            $gateway->refundPassword = $config->refundPassword;
//            $gateway->sharedSecret = $config->sharedSecret;
//            $gateway->timeout = $config->timeout;
//            $gateway->serviceUrl = $config->serviceUrl;
//            $gateway->hostedPaymentConfig = $config->hostedPaymentConfig;
//            $gateway->curlOptions = $config->curlOptions;
//            static::$instance = new static($gateway, $gateway);
//            // set default
//            if ($config->secure3dVersion == null) {
//                $config->secure3dVersion = Secure3dVersion::ONE;
//            }
//
//            // secure 3d v1
//            if ($config->secure3dVersion === Secure3dVersion::ONE || $config->secure3dVersion === Secure3dVersion::ANY) {
//                static::$instance->setSecure3dProvider(Secure3dVersion::ONE, $gateway);
//            }
//
//            // secure 3d v2
//            if ($config->secure3dVersion === Secure3dVersion::TWO || $config->secure3dVersion === Secure3dVersion::ANY) {
//                $secure3d2 = new Gp3DSProvider();
//                $secure3d2->setMerchantId($config->merchantId);
//                $secure3d2->setAccountId($config->accountId);
//                $secure3d2->setSharedSecret($config->sharedSecret);
//                $secure3d2->serviceUrl = $config->environment == Environment::TEST ? ServiceEndpoints::THREE_DS_AUTH_TEST : ServiceEndpoints::THREE_DS_AUTH_PRODUCTION;
//                $secure3d2->setMerchantContactUrl($config->merchantContactUrl);
//                $secure3d2->setMethodNotificationUrl($config->methodNotificationUrl);
//                $secure3d2->setChallengeNotificationUrl($config->challengeNotificationUrl);
//                $secure3d2->timeout = $config->timeout;
//
//                static::$instance->setSecure3dProvider(Secure3dVersion::TWO, $secure3d2);
//            }
        } else {
            if config.serviceUrl.isNilOrEmpty && !config.secretApiKey.isNilOrEmpty {
                let env = config.secretApiKey?.components(separatedBy: "_")[safe: 1]
                if let env = env, env == "prod" {
                    config.serviceUrl = ServiceEndpoints.porticoProduction.rawValue
                } else {
                    config.serviceUrl = ServiceEndpoints.porticoTest.rawValue
                }
            }

//            $gateway = new PorticoConnector();
//            $gateway->siteId = $config->siteId;
//            $gateway->licenseId = $config->licenseId;
//            $gateway->deviceId = $config->deviceId;
//            $gateway->username = $config->username;
//            $gateway->password = $config->password;
//            $gateway->secretApiKey = $config->secretApiKey;
//            $gateway->developerId = $config->developerId;
//            $gateway->versionNumber = $config->versionNumber;
//            $gateway->timeout = $config->timeout;
//            $gateway->serviceUrl = $config->serviceUrl . '/Hps.Exchange.PosGateway/PosGatewayService.asmx';
//            $gateway->curlOptions = $config->curlOptions;
//
//            $payplanEndPoint = (strpos(strtolower($config->serviceUrl), 'cert.') > 0) ?
//                                '/Portico.PayPlan.v2/':
//                                '/PayPlan.v2/';
//
//            $recurring = new PayPlanConnector();
//            $recurring->siteId = $config->siteId;
//            $recurring->licenseId = $config->licenseId;
//            $recurring->deviceId = $config->deviceId;
//            $recurring->username = $config->username;
//            $recurring->password = $config->password;
//            $recurring->secretApiKey = $config->secretApiKey;
//            $recurring->developerId = $config->developerId;
//            $recurring->versionNumber = $config->versionNumber;
//            $recurring->timeout = $config->timeout;
//            $recurring->serviceUrl = $config->serviceUrl . $payplanEndPoint;
//            $recurring->curlOptions = $config->curlOptions;
//
//            static::$instance = new static($gateway, $recurring);
        }
    }

    /// Gets the configured gateway connector
    /// - Returns: PaymentGateway?
    public func getClient() -> PaymentGateway? {
        return gateway
    }

    /// Gets the configured recurring gateway connector
    /// - Returns: IRecurringService?
    public func getRecurringClient() -> IRecurringService? {
        return recurring
    }

    func getReportingService() -> ReportingService? {
        return reportingService
    }

    public func getSecure3d(version: Secure3dVersion) throws -> Secure3dProvider {
        guard let provider = secure3dProviders[version] else {
            throw ConfigurationException.generic(message: "Secure 3d is not configured for version \(version)")
        }
        return provider
    }
}

//public class ServicesContainer {
//    private var configurations = [String: ConfiguredServices]()
//
//    public static let shared = ServicesContainer()
//
//    public static func configure(config: ServiceConfig) {
//        config.validate()
//    }
//
//    public static func configureService<T: Configuration>(config: T) {
//        if !config.validated {
//            config.validate()
//        }
//        let cs = shared.get
//    }
//}
