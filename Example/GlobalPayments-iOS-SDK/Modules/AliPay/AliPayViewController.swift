import UIKit
import GlobalPayments_iOS_SDK

final class AliPayViewController: BaseViewController<AliPayViewModel> {
    
    private lazy var customView = {
        let view = AliPayView()
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
            self?.viewModel?.hideLoading.executer()
            self?.customView.toBottomView()
        }
        
        customView.defaultValues()
    }
}

extension AliPayViewController: AliPayViewDelegate {
    
    func onChargePressed() {
        viewModel?.doAliPayTransaction()
    }
    
    func fieldDataChanged(value: String, type: GpFieldsEnum) {
        viewModel?.fieldDataChanged(value: value, type: type)
    }
}
