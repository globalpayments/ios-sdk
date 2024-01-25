import UIKit
import GlobalPayments_iOS_SDK

final class PaymentOperationFormViewController: BaseViewController<PaymentOperationFormViewModel> {
    
    private lazy var customView = {
        let view = PaymentOperationFormView()
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
        
        viewModel?.showDataResponse.bind { [weak self] type, data in
            self?.customView.setResponseData(type, data: data)
            self?.customView.toBottomView()
            self?.viewModel?.hideLoading.executer()
        }
        
        customView.defaultValues()
    }
}

extension PaymentOperationFormViewController: PaymentOperationFormViewDelegate {
    
    func onSubmitPressed() {
        viewModel?.onSubmitPressed()
    }
    
    func fieldDataChanged(value: String, type: GpFieldsEnum) {
        viewModel?.fieldDataChanged(value: value, type: type)
    }
}
