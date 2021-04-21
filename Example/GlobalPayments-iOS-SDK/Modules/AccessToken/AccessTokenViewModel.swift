import Foundation
import GlobalPayments_iOS_SDK

protocol AccessTokenInput {
    func createToken(from form: AccessTokenForm)
}

protocol AccessTokenOutput: class {
    func showTokenView(token: AccessTokenInfo)
    func showErrorView(error: Error?)
}

final class AccessTokenViewModel: AccessTokenInput {

    weak var view: AccessTokenOutput?

    func createToken(from form: AccessTokenForm) {
        GpApiService.generateTransactionKey(
            environment: form.environment,
            appId: form.appId,
            appKey: form.appKey,
            secondsToExpire: form.secondsToExpire,
            intervalToExpire: form.interval) { [weak self] accessTokenInfo, error in
            UI {
                guard let accessTokenInfo = accessTokenInfo else {
                    self?.view?.showErrorView(error: error)
                    return
                }
                self?.view?.showTokenView(token: accessTokenInfo)
            }
        }
    }
}
