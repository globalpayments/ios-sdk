import UIKit
import GlobalPayments_iOS_SDK

protocol ConfigurationDataViewDelegate: AnyObject {
    func onUpdateConfiguration()
}

final class ConfigurationViewController: BaseViewController<ConfigurationViewModel> {
    
    weak var delegate: ConfigurationDataViewDelegate?
    
    private lazy var customView = {
        let view = ConfigurationView()
        view.delegate = self
        return view
    }()
    
    override func loadView() {
        view = customView
        hideKeyboardWhenTappedAround()
    }
    
    override func fillUI() {
        super.fillUI()
        
        viewModel?.initConfig.bind { [weak self] in
            self?.customView.setDefaultData($0)
        }
        
        viewModel?.configUpdated.bind { [weak self] in
            self?.delegate?.onUpdateConfiguration()
            self?.dismiss(animated: true, completion: nil)
        }
    }
}

extension ConfigurationViewController: ConfigurationViewDelegate {
    
    func fieldDataChanged(value: String, type: GpFieldsEnum) {
        viewModel?.fieldDataChanged(value: value, type: type)
    }
    
    func saveConfigurationPressed() {
        viewModel?.saveConfiguration()
    }
    
    func backButtonPressed() {
        dismiss(animated: true, completion: nil)
    }
}
