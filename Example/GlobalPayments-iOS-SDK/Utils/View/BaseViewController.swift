import UIKit

class BaseViewController<T: BaseViewModel>: UIViewController {
    
    var viewModel: T? {
        didSet {
            fillUI()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setStatusBar()
        viewModel?.viewDidLoad()
        hideKeyboardWhenTappedAround()
    }
    
    func fillUI() {
        viewModel?.goSettingsScreen.bind { [weak self] in
            self?.showConfigurationModule(.fullScreen)
        }
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        if #available(iOS 13.0, *) {
            return .darkContent
        } else {
            return .lightContent
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    private func setStatusBar() {
        if #available(iOS 13.0, *) {
            let window = UIApplication.shared.windows.filter {$0.isKeyWindow}.first
            let statusBar = UIView(frame: window?.windowScene?.statusBarManager?.statusBarFrame ?? CGRect.zero)
            statusBar.backgroundColor = .white
            window?.addSubview(statusBar)
        } else {
            UIApplication.shared.statusBarUIView?.backgroundColor = .white
        }
    }
    
    private func showConfigurationModule(_ modalPresentationStyle: UIModalPresentationStyle) {
        let module = ConfigurationGBBuilder.build(with: self)
        module.modalPresentationStyle = modalPresentationStyle
        navigationController?.present(module, animated: true, completion: nil)
    }
}

extension BaseViewController: ConfigurationDataViewDelegate {

    func onUpdateConfiguration() {
        viewModel?.checkConfig()
    }
}

extension BaseViewController: BaseViewDelegate {
    
    func backViewAction() {
        navigationController?.popViewController(animated: true)
    }
    
    func settingsAction() {
        viewModel?.settingsAction()
    }
}
