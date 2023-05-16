import UIKit
import GlobalPayments_iOS_SDK

final class PaypalViewController: UIViewController, StoryboardInstantiable {
    
    static var storyboardName = "Paypal"
    
    var viewModel: PaypalViewInput!

    @IBOutlet weak var typeTextField: UITextField!
    @IBOutlet weak var amountTextField: UITextField!
    @IBOutlet weak var payButton: UIButton!
    @IBOutlet weak var supportView: UIView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        print("did load")
    }

    private func setupUI() {
        title = "paypal.title".localized()
        hideKeyboardWhenTappedAround()
        payButton.apply(style: .globalPayStyle, title: "paypal.title.button".localized())
        typeTextField.loadDropDownData(PaypalType.allCases.map { $0.mapped(for: .gpApi) ?? .empty}, onSelectItem: onChangeTypePayer)
        activityIndicator.stopAnimating()
    }
    
    private func onChangeTypePayer(_ typePayer: String) {
        viewModel.setType(typePayer)
    }
    
    @IBAction func doTransactionAction(_ sender: Any) {
        viewModel.doPaypalTransaction(amountTextField.text)
        activityIndicator.startAnimating()
        supportView.clearSubviews()
    }
}

extension PaypalViewController: PaypalViewOutput {
    
    func showErrorView(error: Error?) {
        activityIndicator.stopAnimating()
        let errorView = ErrorView.instantiateFromNib()
        errorView.display(error)
        supportView.addSubview(errorView)
        errorView.bindFrameToSuperviewBounds()
    }
    
    func showTransaction(_ transaction: Transaction) {
        activityIndicator.stopAnimating()
        let transactionView = TransactionView.instantiateFromNib()
        transactionView.display(transaction)
        supportView.addSubview(transactionView)
        transactionView.bindFrameToSuperviewBounds()
    }
}
