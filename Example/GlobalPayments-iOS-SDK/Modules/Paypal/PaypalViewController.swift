import UIKit
import GlobalPayments_iOS_SDK

final class PaypalViewController: BaseViewController<PaypalViewModel> {
    
    private lazy var customView = {
        let view = PaypalView()
        view.delegateView = self
        view.delegate = self
        return view
    }()
    
    override func loadView() {
        view = customView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(viewDidBecomeActive), name: UIApplication.didBecomeActiveNotification, object: nil)
    }
    
    @objc func viewDidBecomeActive() {
        viewModel?.validateTransaction()
    }
    
    override func fillUI() {
        super.fillUI()
        
        viewModel?.showLoading.bind { [weak self] in
            self?.customView.showLoading(true)
        }
        
        viewModel?.hideLoading.bind { [weak self] in
            self?.customView.showLoading(false)
        }
        
        viewModel?.enableButtons.bind { [weak self] enable in
            self?.customView.enableButtons(enable)
        }
        
        viewModel?.openWebView.bind { url in
            UIApplication.shared.open(url)
        }
        
        viewModel?.showDataResponse.bind { [weak self] type, data in
            self?.customView.setResponseData(type, data: data)
            self?.viewModel?.hideLoading.executer()
        }
        
        customView.defaultValues()
    }
}

extension PaypalViewController: PaypalViewViewDelegate {
    
    func onChargeButtonAction() {
        viewModel?.chargeTrasaction()
    }
    
    func onAuthorizeButtonAction() {
        viewModel?.authorizeTransaction()
    }
    
    func fieldDataChanged(value: String, type: GpFieldsEnum) {
        viewModel?.fieldDataChanged(value: value, type: type)
    }
}
