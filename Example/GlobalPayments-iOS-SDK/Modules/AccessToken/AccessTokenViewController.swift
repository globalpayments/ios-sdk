import UIKit
import GlobalPayments_iOS_SDK

final class AccessTokenViewController: BaseViewController<AccessTokenViewModel> {

    private lazy var customView = {
        let view = AccessTokenDataView()
        view.delegateView = self
        view.delegate = self
        return view
    }()
    
    override func loadView() {
        view = customView
    }

    override func fillUI() {
        super.fillUI()
        viewModel?.initPermissions.bind { [weak self] permissions in
            self?.customView.setPermissions(permissions)
        }
        viewModel?.validateCreateAccessButton.bind { [weak self] enableButton in
            self?.customView.enableCreateAccessButton(enableButton)
        }
        viewModel?.showLoading.bind { [weak self] in
            self?.customView.showLoading(true)
        }
        viewModel?.hideLoading.bind { [weak self] in
            self?.customView.showLoading(false)
        }
        
        viewModel?.showDataResponse.bind { [weak self] type, data in
            self?.customView.setResponseData(type, data: data)
            self?.customView.toBottomView()
        }
        customView.setDefaultData()
    }
}

extension AccessTokenViewController: AccessTokenDataDelegate {
    
    func fieldDataChanged(value: String, type: GpFieldsEnum) {
        viewModel?.fieldDataChanged(value: value, type: type)
    }
    
    func createAccessTokenAction() {
        viewModel?.createToken()
    }
}
