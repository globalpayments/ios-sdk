import UIKit
import GlobalPayments_iOS_SDK

final class FasterPaymentsFormViewController: UIViewController, StoryboardInstantiable {
    
    static var storyboardName = "OpenBanking"
    @IBOutlet weak var accountNumberTextField: UITextField!
    @IBOutlet weak var sortCodeTextField: UITextField!
    @IBOutlet weak var accountNameTextField: UITextField!
    @IBOutlet weak var payButton: UIButton!
    @IBOutlet weak var supportView: UIView!
    @IBOutlet private weak var activityIndicator: UIActivityIndicatorView!
    
    private let viewModel = OpenBankingViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    private func setupUI() {
        hideKeyboardWhenTappedAround()
        title = "openBanking.fasterPayments.title.button".localized()
        payButton.apply(style: .globalPayStyle, title: "openBanking.fasterPayments.title.button".localized())
        activityIndicator.stopAnimating()
        viewModel.view = self
    }
    
    @IBAction func onPayAction(_ sender: Any) {
        guard let accountNumber = accountNumberTextField.text, !accountNumber.isEmpty,
              let sortCode = sortCodeTextField.text, !sortCode.isEmpty,
              let accountName = accountNameTextField.text, !accountName.isEmpty else {
            showAlert(message: "openBanking.error.fields.empty".localized())
            return
        }
        
        activityIndicator.startAnimating()
        viewModel.fasterPaymentTransation(FasterPaymentsForm(accountNumber: accountNumber, sortCode: sortCode, accountName: accountName))
    }
}

extension FasterPaymentsFormViewController: OpenBankingViewOutput {
    
    func showErrorView(error: Error?) {
        activityIndicator.stopAnimating()
        let errorView = ErrorView.instantiateFromNib()
        errorView.display(error)
        supportView.addSubview(errorView)
        errorView.bindFrameToSuperviewBounds()
    }
    
    func showUrlOpen(_ url: URL, transaction: Transaction) {
        activityIndicator.stopAnimating()
        let storyboard = UIStoryboard(name: "OpenBanking", bundle: nil)
        if #available(iOS 13.0, *) {
            let secondVC: OpenBankingPaymentProcessingViewController = storyboard.instantiateViewController(identifier: "OpenBankingPaymentProcessingViewController")
            secondVC.transaction = transaction
            present(secondVC, animated: true, completion: nil)
        }
        UIApplication.shared.open(url)
    }
}
