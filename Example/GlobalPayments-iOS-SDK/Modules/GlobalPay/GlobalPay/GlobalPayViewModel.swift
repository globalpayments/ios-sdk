import Foundation
import GlobalPayments_iOS_SDK

protocol GlobalPayViewInput {
    func onViewDidLoad()
    func onUpdateConfig()
}

protocol GlobalPayViewOutput: AnyObject {
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
            let accessTokenInfo =  AccessTokenInfo()
            
            if let accountName = appConfig.transactionProcessing, !accountName.isEmpty {
                accessTokenInfo.transactionProcessingAccountName = accountName
            }
           
            accessTokenInfo.tokenizationAccountName = appConfig.tokenization
            
            let config = GpApiConfig(
                appId: appConfig.appId,
                appKey: appConfig.appKey,
                secondsToExpire: appConfig.secondsToExpire,
                intervalToExpire: appConfig.intervalToExpire,
                channel: appConfig.channel,
                language: appConfig.language,
                country: appConfig.country,
                accessTokenInfo: accessTokenInfo,
                challengeNotificationUrl: appConfig.challengeNotificationUrl,
                methodNotificationUrl: appConfig.methodNotificationUrl,
                merchantContactUrl: appConfig.merchantContactUrl,
                merchantId: appConfig.merchantId
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
