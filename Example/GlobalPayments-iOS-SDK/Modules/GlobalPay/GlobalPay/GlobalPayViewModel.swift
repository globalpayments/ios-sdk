import Foundation
import GlobalPayments_iOS_SDK

protocol GlobalPayViewInput {
    func onViewDidLoad()
    func onUpdateConfig()
}

protocol GlobalPayViewOutput: class {
    func displayConfigModule()
    func displayError(_ error: Error)
}

final class GlobalPayViewModel: GlobalPayViewInput {

    weak var view: GlobalPayViewOutput?

    private let configuration: Configuration

    init(configuration: Configuration) {
        self.configuration = configuration
    }

    func onViewDidLoad() {
        checkConfig()
    }

    func onUpdateConfig() {
        checkConfig()
    }

    private func checkConfig() {
        guard let appConfig = configuration.loadConfig() else {
            view?.displayConfigModule()
            return
        }
        configureContainer(with: appConfig)
    }

    private func configureContainer(with appConfig: Config) {
        do {
            let config = GpApiConfig(
                appId: appConfig.appId,
                appKey: appConfig.appKey,
                secondsToExpire: appConfig.secondsToExpire,
                intervalToExpire: appConfig.intervalToExpire,
                channel: appConfig.channel,
                language: appConfig.language,
                country: appConfig.country
            )
            config.environment = .test
            try ServicesContainer.configureService(
                config: config
            )
        } catch {
            view?.displayError(error)
        }
    }
}
