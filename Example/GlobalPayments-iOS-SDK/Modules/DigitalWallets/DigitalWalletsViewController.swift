import UIKit
import PassKit

final class DigitalWalletsViewController: BaseViewController<DigitalWalletsViewModel> {
    
    private lazy var customView = {
        let view = DigitalWalletsView()
        view.delegateView = self
        view.delegate = self
        return view
    }()
    
    override func loadView() {
        view = customView
    }
    
    override func fillUI() {
        super.fillUI()
        
        viewModel?.showLoading.bind { [weak self] in
            self?.customView.showLoading(true)
        }
        
        viewModel?.hideLoading.bind { [weak self] in
            self?.customView.showLoading(false)
        }
        
        viewModel?.paymentGenerated.bind { [weak self] paymentRquest in
            self?.openApplePayView(paymentRquest)
        }
        viewModel?.defaultValues.bind { [weak self] in
            self?.customView.defaultValues()
        }
        viewModel?.showDataResponse.bind { [weak self] type, data in
            self?.customView.setResponseData(type, data: data)
        }
    }
    
    func openApplePayView(_ paymentRequest: PKPaymentRequest?) {
        if PKPaymentAuthorizationViewController.canMakePayments(), let paymentRequest = paymentRequest {
            let payAuth = PKPaymentAuthorizationViewController(paymentRequest: paymentRequest)
            payAuth?.delegate = self
            self.present(payAuth!, animated:true, completion: nil)
        }
    }
}

extension DigitalWalletsViewController: PKPaymentAuthorizationViewControllerDelegate{

    func paymentAuthorizationViewController(_ controller: PKPaymentAuthorizationViewController, didAuthorizePayment payment: PKPayment, completion:(@escaping (PKPaymentAuthorizationStatus) -> Void)) {
        let tokenGenerated: String? = NSString(data:payment.token.paymentData, encoding:String.Encoding.utf8.rawValue) as? String
        viewModel?.showTokenGenerated(tokenGenerated)
        completion(PKPaymentAuthorizationStatus.success)
    }
    
    func paymentAuthorizationViewControllerDidFinish(_ controller: PKPaymentAuthorizationViewController) {
        controller.dismiss(animated: true, completion: nil)
    }
}

extension DigitalWalletsViewController: DigitalWalletsViewDelegate {
    
    func onApplePayButtonAction() {
        viewModel?.generatePaymentRequest()
    }
    
    func fieldDataChanged(value: String, type: GpFieldsEnum) {
        viewModel?.fieldDataChanged(value: value, type: type)
    }
}
