import Foundation

class ConfigurationUseCaseImplementation: ConfigurationDataUseCase {
    
    private let defaults: UserDefaults
    
    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }
    
    func loadConfig() -> Config? {
        defaults.get(.appConfiguration)
    }

    func saveConfig(_ config: Config) throws {
        try defaults.set(.appConfiguration, to: config)
    }
}
