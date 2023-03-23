import Foundation
import GlobalPayments_iOS_SDK

protocol MerchantViewOutput: AnyObject{
    func showErrorView(error: Error?)
    func showUser(_ user: User)
}

protocol MerchantViewInput: AnyObject{
    func findUserById(_ merchantId: String)
}

final class MerchantViewModel: MerchantViewInput {
    
    weak var view: MerchantViewOutput?
    
    func findUserById(_ merchantId: String) {
        PayFacService.getMerchantInfo(merchantId)
            .execute(completion: showOutput)
    }
    
    private func showOutput(user: User?, error: Error?) {
        UI {
            guard let user = user else {
                self.view?.showErrorView(error: error)
                return
            }
            self.view?.showUser(user)
        }
    }
}
