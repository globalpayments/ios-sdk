import UIKit
import GlobalPayments_iOS_SDK

final class HostedFieldsViewController: BaseViewController<HostedFieldsViewModel> {
    
    private lazy var customView = {
        let view = HostedFieldsView()
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
        
        viewModel?.tokenGenerated.bind { [weak self] token in
            self?.customView.showHostedFields(token)
        }
        viewModel?.showDataResponse.bind { [weak self] type, data in
            self?.customView.setResponseData(type, data: data)
            self?.customView.toBottomView()
        }
    }
}

extension HostedFieldsViewController: HostedFieldsViewDelegate {
    
    func onHostedFieldsTokenError(_ message: String) {
        viewModel?.onHostedFieldsTokenError(message)
    }
    
    func onSubmitAction() {
        viewModel?.onSubmitAction()
    }
    
    func onTokenizedSuccess(token: String, cardBrand: String) {
        viewModel?.checkEnrollment(token, brand: cardBrand)
    }
    
    func fieldDataChanged(value: String, type: GpFieldsEnum) {
        viewModel?.fieldDataChanged(value: value, type: type)
    }
}
