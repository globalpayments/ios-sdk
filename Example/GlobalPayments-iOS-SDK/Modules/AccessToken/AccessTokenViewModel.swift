import Foundation
import GlobalPayments_iOS_SDK

protocol AccessTokenInput {
    func createToken()
}

protocol AccessTokenOutput: AnyObject {
    func showTokenView(token: AccessTokenInfo)
    func showErrorView(error: Error?)
}

final class AccessTokenViewModel: BaseViewModel, AccessTokenInput {

    weak var view: AccessTokenOutput?
    
    var initPermissions: Dynamic<[String]> = Dynamic([])
    var validateCreateAccessButton: Dynamic<Bool> = Dynamic(false)
    
    private var appId: String?
    private var appKey: String?
    private var secondsToExpire: Int?
    private var env: Environment?
    private var interval: IntervalToExpire?
    private var permissions: [String] = []
    private var form: AccessTokenForm?
    
    override func viewDidLoad() {
        initPermissions.value = PermissionsEnum.allCases.map{ $0.rawValue }
    }

    func createToken() {
        guard let form = form else { return }
        showLoading.executer()
        GpApiService.generateTransactionKey(
            environment: form.environment,
            appId: form.appId,
            appKey: form.appKey,
            secondsToExpire: form.secondsToExpire,
            intervalToExpire: form.interval) { [weak self] accessTokenInfo, error in
            UI {
                self?.hideLoading.executer()
                guard let accessTokenInfo = accessTokenInfo else {
                    self?.showDataResponse.value = (.error, error as Any)
                    return
                }                
                self?.showDataResponse.value = (.success, accessTokenInfo)
            }
        }
    }
    
    func fieldDataChanged(value: String, type: GpFieldsEnum) {
        switch type {
        case .appId:
            appId = value
        case .appKey:
            appKey = value
        case .secondsToExpire:
            secondsToExpire = Int(value)
        case .env:
            env = Environment(value: value)
        case .interval:
            interval = IntervalToExpire(value: value)
        default:
            break
        }
        
        validateFields()
    }
    
    private func validateFields() {
        guard let appId = appId, !appId.isEmpty,
              let appKey = appKey, !appKey.isEmpty,
              let secondsToExpire = secondsToExpire,
              let env = env,
              let interval = interval else { return }
        
        form =  AccessTokenForm(
            appId: appId,
            appKey: appKey,
            secondsToExpire: secondsToExpire,
            environment: env,
            interval: interval,
            permissions: permissions)
        
        validateCreateAccessButton.value = true
    }
}
