import Foundation
import GlobalPayments_iOS_SDK

protocol AccessTokenInput {
    func createToken()
}

protocol AccessTokenOutput: class {
    func showTokenView(token: AccessTokenInfo)
    func showErrorView(error: Error?)
}

final class AccessTokenViewModel: AccessTokenInput {

    weak var view: AccessTokenOutput?

    func createToken() {
        GpApiService.generateTransactionKey(
            environment: Environment.test,
            appId: Constants.gpApiAppID,
            appKey: Constants.gpApiAppKey) { [weak self] accessTokenInfo, error in
            DispatchQueue.main.async {
                guard let accessTokenInfo = accessTokenInfo else {
                    self?.view?.showErrorView(error: error)
                    return
                }
                self?.view?.showTokenView(token: accessTokenInfo)
            }
        }
    }

    deinit {
        print("AccessTokenViewModel deinit")
    }
}
