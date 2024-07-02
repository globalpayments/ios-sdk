import UIKit
import GlobalPayments_iOS_SDK

final class MerchantEditViewController: BaseViewController<MerchantEditViewModel> {
    
    private lazy var customView = {
        let view = MerchantEditView()
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
        
        viewModel?.showAddressScreen.bind {
            let viewController = MerchantAddressBuilder.build(delegate: self, path: .business)
            self.navigationController?.present(viewController, animated: true, completion: nil)
        }
        
        viewModel?.setBillingLabel.bind { [weak self] label in
            self?.customView.setBillingLabel(label)
        }
        
        viewModel?.showDataResponse.bind { [weak self] type, data in
            self?.customView.setResponseData(type, data: data)
            self?.viewModel?.hideLoading.executer()
            self?.customView.toBottomView()
        }
        
        customView.defaultValues()
        viewModel?.setMockData()
    }
}

extension MerchantEditViewController: MerchantEditViewDelegate {
    
    func onEditAccount() {
        viewModel?.editMerchant()
    }
    
    func onBillingPressed() {
        viewModel?.onBillingAddressPressed()
    }
    
    func fieldDataChanged(value: String, type: GpFieldsEnum) {
        viewModel?.fieldDataChanged(value: value, type: type)
    }
}

extension MerchantEditViewController: MerchantAddressDelegate {
    
    func onSubmitAddress(address: Address, path: MerchantAddressPath) {
        viewModel?.setAddress(address)
    }
}
