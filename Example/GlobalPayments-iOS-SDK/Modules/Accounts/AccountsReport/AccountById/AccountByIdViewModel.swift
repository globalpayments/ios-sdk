import Foundation
import GlobalPayments_iOS_SDK

final class AccountByIdViewModel: BaseViewModel {
    
    private lazy var accountId: String = ""
    
    func getAccountById() {
        showLoading.executer()
        PayFacService.getMerchantInfo(accountId)
            .execute(completion: showOutput)
    }
    
    private func showOutput(account: User?, error: Error?) {
        UI {
            guard let account = account else {
                if let error = error as? GatewayException {
                    self.showDataResponse.value = (.error, error)
                }
                return
            }
            self.showDataResponse.value = (.success, account)
        }
    }
    
    func fieldDataChanged(value: String, type: GpFieldsEnum) {
        switch type {
        case .accountId:
            accountId = value
        default:
            break;
        }
    }
}
