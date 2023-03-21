import Foundation

protocol ConfigurationViewInput {
    func onViewDidLoad()
    func saveConfig(_ config: Config)
}

protocol ConfigurationViewOutput: class {
    func displayConfig(_ config: Config)
    func displayError(_ error: Error)
    func closeModule()
}

final class ConfigurationViewModel: ConfigurationViewInput {

    weak var view: ConfigurationViewOutput?

    private let configuration: Configuration

    init(configuration: Configuration) {
        self.configuration = configuration
    }

    func onViewDidLoad() {
        if let config = configuration.loadConfig() {
            view?.displayConfig(config)
        }
    }

    func saveConfig(_ config: Config) {
        do {
            try configuration.saveConfig(config)
            view?.closeModule()
        } catch {
            view?.displayError(error)
        }
    }
}
