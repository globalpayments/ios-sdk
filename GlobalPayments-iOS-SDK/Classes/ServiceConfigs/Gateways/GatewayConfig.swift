import Foundation

public class GatewayConfig: Configuration {
    var gatewayProvider: GatewayProvider

    // MARK: - GP Data Services

    /// Client Id for Global Payments Data Services
    public var dataClientId: String?
    /// Client Secret for Global Payments Data Services
    public var dataClientSecret: String?
    /// The UserId for the Global Payment Data Services
    public var dataClientUserId: String?
    /// The Url of the Global Data Service
    public var dataClientSeviceUrl: String?

    init(gatewayProvider: GatewayProvider) {
        self.gatewayProvider = gatewayProvider
    }

    override func configureContainer(services: ConfiguredServices) {
//        let reportingService = DataSer
    }
}

//
//    internal override void ConfigureContainer(ConfiguredServices services) {
//        var reportingService = new DataServicesConnector {
//            ClientId = DataClientId,
//            ClientSecret = DataClientSecret,
//            UserId = DataClientUserId,
//            ServiceUrl = DataClientSeviceUrl ?? "https://globalpay-test.apigee.net/apis/reporting/",
//            Timeout = Timeout
//        };
//        services.ReportingService = reportingService;
//    }
//
//    internal override void Validate() {
//        base.Validate();
//
//        // data client
//        if (!string.IsNullOrEmpty(DataClientId) || !string.IsNullOrEmpty(DataClientSecret)) {
//            if (string.IsNullOrEmpty(DataClientId) || string.IsNullOrEmpty(DataClientSecret)) {
//                throw new ConfigurationException("Both \"DataClientID\" and \"DataClientSecret\" are required for data client services.");
//            }
//            if (string.IsNullOrEmpty(DataClientUserId)) {
//                throw new ConfigurationException("DataClientUserId required for data client services.");
//            }
//        }
//    }
//}
