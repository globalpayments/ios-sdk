import UIKit

final class UnifiedPaymentsViewController: BaseViewController<UnifiedPaymentsViewModel> {
    
    private lazy var customView = {
        let view = UnifiedPaymentsView()
        view.delegate = self
        view.delegateView = self
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
        
        viewModel?.validateChargeButton.bind { [weak self] enable in
            self?.customView.enableChargeButton(enable)
        }
        
        viewModel?.showDataResponse.bind { [weak self] type, data in
            self?.customView.setResponseData(type, data: data)
            self?.customView.toBottomView()
            self?.viewModel?.hideLoading.executer()
        }
    }
}

extension UnifiedPaymentsViewController: UnifiedPaymentsViewDelegate {
    
    func makeRecurringEnabled(_ value: Bool) {
        viewModel?.setMakeRecurring(value)
    }
    
    func fieldDataChanged(value: String, type: GpFieldsEnum) {
        viewModel?.fieldDataChanged(value: value, type: type)
    }
    
    func onChargeAction() {
        viewModel?.makePayment()
    }
}
