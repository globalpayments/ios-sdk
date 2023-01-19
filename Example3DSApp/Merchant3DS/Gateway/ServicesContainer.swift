import Foundation

public class ServicesContainer {

    public static let shared = ServicesContainer()
    private var providers = [String: ApiConnector]()
    
    func client() -> ApiConnector {
        return provider()
    }
    
    public static func configureProvider(provider: Gateway3ds, providerName: String = "default") throws {
        let configuredProvider = shared.provider(for: providerName)
        shared.addProvider(providerName: providerName, provider: configuredProvider)
    }
    
    private func provider(for providerName: String = "default") -> ApiConnector {
        return providers[providerName] ?? ApiConnector()
    }
    
    private func addProvider(providerName: String, provider: ApiConnector) {
        providers[providerName] = provider
    }
}
