import UIKit

final class AccountByIdViewController: BaseViewController<AccountByIdViewModel> {
    
    private lazy var customView = {
        let view = AccountByIdView()
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
        }
        
        customView.defaultValues()
    }
}

extension AccountByIdViewController: AccountByIdViewDelegate {
    
    func fieldDataChanged(value: String, type: GpFieldsEnum) {
        viewModel?.fieldDataChanged(value: value, type: type)
    }
    
    func onSubmitButtonPressed() {
        viewModel?.getAccountById()
    }
}
