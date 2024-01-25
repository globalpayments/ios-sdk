import Foundation
import GlobalPayments_iOS_SDK
import GirdersSwift

class BaseViewModel {
    
    private lazy var configurationUseCase: ConfigurationDataUseCase = Container.resolve()
    
    var showLoading: Dynamic<Void> = Dynamic(())
    var hideLoading: Dynamic<Void> = Dynamic(())
    var showError: Dynamic<String> = Dynamic(String())
    var showLoanError: Dynamic<String> = Dynamic(String())
    var titleScreen: Dynamic<String> = Dynamic(String())
    var showDataResponse: Dynamic<(ResponseViewType, Any)> = Dynamic((.error, ()))
    var goSettingsScreen: Dynamic<Void> = Dynamic(())
    
    func viewDidLoad() {
        checkConfig()
    }
    
    func settingsAction() {
        goSettingsScreen.executer()
    }
    
    func checkConfig() {
        guard let appConfig = configurationUseCase.loadConfig() else {
            settingsAction()
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
            settingsAction()
        }
    }
}
