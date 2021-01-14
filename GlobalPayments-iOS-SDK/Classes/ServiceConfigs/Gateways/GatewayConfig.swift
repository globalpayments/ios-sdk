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
        let reportingService = DataServicesConnector()
        reportingService.clientId = dataClientId
        reportingService.clientSecret = dataClientSecret
        reportingService.userId = dataClientUserId
        reportingService.serviceUrl = dataClientSeviceUrl
        services.reportingService = reportingService
    }

    override func validate() throws {
        try super.validate()

        if !dataClientId.isNilOrEmpty || !dataClientSecret.isNilOrEmpty {
            if dataClientId.isNilOrEmpty || dataClientSecret.isNilOrEmpty {
                throw ConfigurationException(
                    message: "Both \"DataClientID\" and \"DataClientSecret\" are required for data client services."
                )
            }
            if dataClientUserId.isNilOrEmpty {
                throw ConfigurationException(
                    message: "DataClientUserId required for data client services."
                )
            }
        }
    }
}
