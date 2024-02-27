import Foundation

/// Maintains references to the currently configured gateway/device objects
/// The public `ServicesContainer.configure` method is the only call
/// required of the integrator to configure the SDK's various gateway/device
/// interactions. The configured gateway/device objects are handled
/// internally by exposed APIs throughout the SDK.
public class ServicesContainer {
    
    public static let shared = ServicesContainer()
    
    private var configurations = [String: ConfiguredServices]()
    
    /// Configure the SDK's various gateway/device interactions
    public static func configure(config: ServicesConfig,
                                 configName: String = "default") throws {
        try config.validate()
        try configureService(config: config.gatewayConfig, configName: configName)
    }
    
    public static func configureService<T: Configuration>(config: T?,
                                                          configName: String = "default") throws {
        if let config = config {
            if !config.validated {
                try config.validate()
            }
            
            let configuredService = shared.configuration(for: configName)
            config.configureContainer(services: configuredService)
            
            shared.addConfiguration(configName: configName, config: configuredService)
        }
    }
    
    private func configuration(for configName: String) -> ConfiguredServices {
        return configurations[configName] ?? ConfiguredServices()
    }
    
    private func addConfiguration(configName: String, config: ConfiguredServices) {
        configurations[configName] = config
    }
    
    public func removeConfiguration(configName: String) {
        configurations.removeValue(forKey: configName)
    }
    
    func secure3DProvider(configName: String,
                          version: Secure3dVersion) throws -> Secure3dProvider {
        guard let configuredService = configurations[configName] else {
            throw ConfigurationException(
                message: "Secure 3d is not configured on the connector."
            )
        }
        guard let provider = configuredService.secure3DProvider(for: version) else {
            throw ConfigurationException(
                message: "Secure 3d is not configured for version \(version)"
            )
        }
        return provider
    }
    
    func reportingClient(configName: String) throws -> ReportingServiceType {
        guard let reportingService = configurations[configName]?.reportingService else {
            throw ApiException(
                message: "The specified configuration has not been configured for reporting."
            )
        }
        return reportingService
    }
    
    func client(configName: String) throws -> PaymentGateway {
        guard let gatewayConnector = configurations[configName]?.gatewayConnector else {
            throw ApiException(
                message: "The specified configuration has not been configured for gateway processing."
            )
        }
        return gatewayConnector
    }
    
    func recurringClient(configName: String) throws -> RecurringServiceType {
        guard let recurringConnector = configurations[configName]?.recurringConnector else {
            throw ApiException(
                message: "The specified configuration has not been configured for recurring processing."
            )
        }
        return recurringConnector
    }
    
    func payFacClient(configName: String) throws -> PayFacServiceType {
        guard let payFacProvider = configurations[configName]?.payFacProvider else {
            throw ApiException(
                message: "The specified configuration has not been configured for pay fac."
            )
        }
        return payFacProvider
    }
}
