import UIKit
import GlobalPayments_iOS_SDK

final class PayLinkViewController: BaseViewController<PayLinkViewModel> {
    
    private lazy var customView = {
        let view = PayLinkView()
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
        
        viewModel?.enableButton.bind { [weak self] enable in
            self?.customView.enableButton(enable)
        }
        
        viewModel?.showDataResponse.bind { [weak self] type, data in
            self?.customView.setResponseData(type, data: data)
            self?.viewModel?.hideLoading.executer()
            self?.customView.toBottomView()
        }
        
        customView.defaultValues()
    }
}

extension PayLinkViewController: PayLinkViewDelegate {
    
    func onPaylinkButtonAction() {
        viewModel?.doPayLinkTransaction()
    }
    
    func fieldDataChanged(value: String, type: GpFieldsEnum) {
        viewModel?.fieldDataChanged(value: value, type: type)
    }
}
