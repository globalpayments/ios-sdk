import UIKit

final class AmountViewController: UIViewController, StoryboardInstantiable  {
    
    static let storyboardName = "Amount"
    
    @IBOutlet private weak var activityIndicator: UIActivityIndicatorView!
    
    var viewModel: MerchantViewInput!
    var currentToken: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        activityIndicator.startAnimating()
        viewModel.onViewDidLoad()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    @IBAction func onContinueAction(_ sender: Any) {
        if !currentToken.isEmpty {
            let viewController = MerchantBuilder.build(currentToken, delegate: self)
            viewController.modalPresentationStyle = .pageSheet
            navigationController?.present(viewController, animated: true, completion: nil)
        }
    }
}

extension AmountViewController: TokenizedCardDataDelegate {
    
    func tokenizedCard(token: String, cardType: String) {
        activityIndicator.startAnimating()
        viewModel?.checkEnrollment(token)
    }
}

// MARK: - GlobalPayViewOutput

extension AmountViewController: MerchantViewOutput {
    
    func displayConfigModule() {
    }
    
    func showTokenLoaded(_ token: String) {
        activityIndicator.stopAnimating()
        
        if token.isEmpty {
            return
        }
        currentToken = token
    }
    
    func showNetceteraLoaded() {
    }
    
    func displayError(_ error: Error) {
        let message = String(format: NSLocalizedString("globalpay.container.failure", comment: ""), error.localizedDescription)
        showAlert(message: message)
        activityIndicator.stopAnimating()
    }
    
    func requestError(_ error: Error) {
        UI {
            self.activityIndicator.stopAnimating()
            UI {
                self.activityIndicator.stopAnimating()
                let viewController = ErrorViewController.instantiate()
                viewController.modalPresentationStyle = .pageSheet
                self.navigationController?.present(viewController, animated: true, completion: nil)
            }
        }
    }
    
    func requestSuccess(_ message: String?) {
        if let message = message {
            showAlert(message: message)
        }
        
        UI {
            self.activityIndicator.stopAnimating()
        }
    }
    
    //28. Display Outcome to CardHolder
    func showTransaction(_ transaction: TransactionResponse) {
        UI {
            self.activityIndicator.stopAnimating()
            let viewController = SuccessViewController.instantiate()
            viewController.modalPresentationStyle = .pageSheet
            self.navigationController?.present(viewController, animated: true, completion: nil)
        }
    }
}
