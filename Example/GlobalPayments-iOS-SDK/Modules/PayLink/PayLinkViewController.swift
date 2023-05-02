import UIKit
import GlobalPayments_iOS_SDK

final class PayLinkViewController: UIViewController, StoryboardInstantiable {

    static var storyboardName = "PayLink"

    @IBOutlet weak var typePayerTextField: UITextField!
    @IBOutlet weak var descriptionTextField: UITextField!
    @IBOutlet weak var amountTextField: UITextField!
    @IBOutlet weak var usageLimitTextField: UITextField!
    @IBOutlet weak var submitButton: UIButton!
    @IBOutlet weak var expirationDateTextField: UITextField!
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var supportView: UIView!
    
    var viewModel: PayLinkViewInput!

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setMockData()
    }

    private func setupUI() {
        title = "payLink.title".localized()
        hideKeyboardWhenTappedAround()
        submitButton.apply(style: .globalPayStyle, title: "generic.submit".localized())
        typePayerTextField.loadDropDownData(PaymentMethodUsageMode.allCases.map { $0.mapped(for: .gpApi) ?? .empty}, onSelectItem: onChangeTypePayer)
        expirationDateTextField.loadDate()
        
        activityIndicator.stopAnimating()
    }
    
    private func setMockData() {
        descriptionTextField.text = "Where's the money Lebowsky"
        amountTextField.text = "10"
        usageLimitTextField.text = "1"
        expirationDateTextField.text = Date().format()
    }
    
    // MARK: - Actions

    private func onChangeTypePayer(_ typePayer: String) {
        guard let typePayer = PaymentMethodUsageMode(rawValue: typePayer) else { return }
        
        switch typePayer {
        case .single:
            usageLimitTextField.text = "1"
        case .multiple:
            usageLimitTextField.text = "2"
        }
    }
    @IBAction func onSubmitAction(_ sender: Any) {
        
        guard let usageMode = typePayerTextField.text,
              let usageLimit = usageLimitTextField.text,
              let name = descriptionTextField.text,
              let amount = amountTextField.text,
              let expDate = expirationDateTextField.text else { return }
        
        let form = PayLinkForm(usageMode: usageMode, usageLimit: usageLimit, name: name, amount: NSDecimalNumber(string: amount), expirationDate: expDate)
        viewModel.doPayLinkTransaction(form)
        activityIndicator.startAnimating()
    }
}

extension PayLinkViewController: PayLinkViewOutput {
    
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
