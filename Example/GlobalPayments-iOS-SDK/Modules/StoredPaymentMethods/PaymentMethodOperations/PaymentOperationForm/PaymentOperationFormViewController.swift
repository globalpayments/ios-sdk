import UIKit
import GlobalPayments_iOS_SDK

protocol PaymentOperationFormDelegate: AnyObject {
    func onSubmitForm(_ form: PaymentOperationForm)
}

final class PaymentOperationFormViewController: UIViewController, StoryboardInstantiable {
    
    static var storyboardName = "PaymentMethods"
    
    @IBOutlet private weak var submitButton: UIButton!
    @IBOutlet private weak var paymentOperationLabel: UILabel!
    @IBOutlet private weak var paymentOperationTextField: UITextField!
    @IBOutlet private weak var paymentMethodIdLabel: UILabel!
    @IBOutlet private weak var paymentMethodIdTextField: UITextField!
    @IBOutlet private weak var paymentCardLabel: UILabel!
    @IBOutlet private weak var paymentCardTextField: UITextField!
    @IBOutlet private weak var cardNumberLabel: UILabel!
    @IBOutlet private weak var cardNumberTextField: UITextField!
    @IBOutlet private weak var expiryMonthLabel: UILabel!
    @IBOutlet private weak var expiryMonthTextField: UITextField!
    @IBOutlet private weak var expiryYearLabel: UILabel!
    @IBOutlet private weak var expiryYearTextField: UITextField!
    @IBOutlet private weak var cvnLabel: UILabel!
    @IBOutlet private weak var cvnTextField: UITextField!
    @IBOutlet private weak var paymentOperationStackView: UIStackView!
    @IBOutlet private weak var paymentCardStackView: UIStackView!
    @IBOutlet weak var methodUsageModeLabel: UILabel!
    @IBOutlet weak var methodUsageModeTextField: UITextField!
    @IBOutlet weak var methodUsageModeStackView: UIStackView!
    
    weak var delegate: PaymentOperationFormDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
    }
    
    private func setupUI() {
        hideKeyboardWhenTappedAround()
        title = "payment.operation.form.title".localized()
        navigationItem.rightBarButtonItem = NavigationItems.cancel(self, #selector(onCancelAction)).button
        submitButton.apply(style: .globalPayStyle, title: "payment.operation.form.submit".localized())
        paymentOperationLabel.text = "payment.operation.form.payment.operation".localized()
        paymentOperationTextField.loadDropDownData(PaymentMethodOperationType.allCases.map { $0.rawValue.uppercased() }, onSelectItem: onSelectPaymentOperation)
        methodUsageModeTextField.loadDropDownData(PaymentMethodUsageMode.allCases.map{ $0.rawValue})
        paymentMethodIdLabel.text = "payment.operation.form.payment.method.id".localized()
        paymentMethodIdTextField.placeholder = "payment.operation.form.payment.method.id.placeholder".localized()
        paymentCardLabel.text = "payment.operation.form.payment.card".localized()
        paymentCardTextField.loadDropDownData(PaymentCardModel.models.map { $0.name }, onSelectItem: onChangePaymentCard)
        cardNumberLabel.text = "payment.operation.form.card.number".localized()
        expiryMonthLabel.text = "payment.operation.form.expiry.month".localized()
        expiryYearLabel.text = "payment.operation.form.expiry.year".localized()
        cvnLabel.text = "payment.operation.form.cvn".localized()
    }
    
    // MARK: - Actions
    
    @objc private func onCancelAction() {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction private func onSubmitAction() {
        guard let operationType = PaymentMethodOperationType(value: paymentOperationTextField.text?.lowercased()) else {
            return
        }
        
        let methodUsage = PaymentMethodUsageMode(value: methodUsageModeTextField.text?.uppercased())
        
        let cardNumber = cardNumberTextField.text ?? ""
        let cardExpiryMonthValue = expiryMonthTextField.text ?? ""
        let cardExpiryMonth = Int(cardExpiryMonthValue ) ?? 0
        let cardExpiryYearValue = expiryYearTextField.text ?? ""
        let cardExpiryYear = Int(cardExpiryYearValue ) ?? 0
        let cvn = cvnTextField.text ?? ""
        
        var paymentMethodId = ""
        if operationType != .tokenize {
            guard let token = paymentMethodIdTextField.text, !token.isEmpty else {
                showAlert(message: "payment.operation.form.payment.method.id.alert".localized())
                return
            }
            paymentMethodId = token
        }
        
        let form = PaymentOperationForm(
            operationType: operationType,
            methodUsageMode: methodUsage,
            paymentMethodId: paymentMethodId,
            cardNumber: cardNumber,
            cardExpiryMonth: cardExpiryMonth,
            cardExpiryYear: cardExpiryYear,
            cvn: cvn
        )
        delegate?.onSubmitForm(form)
        dismiss(animated: true, completion: nil)
    }
    
    private func onSelectPaymentOperation(_ operation: String) {
        guard let paymentOperation = PaymentMethodOperationType(rawValue: operation.lowercased()) else {
            return
        }
        
        UIView.animate(withDuration: 0.0,
                       delay: 0.0,
                       usingSpringWithDamping: 0.9,
                       initialSpringVelocity: 1,
                       options: [],
                       animations: { [weak self] in
            switch paymentOperation {
            case .tokenize:
                self?.optionTokenizeSelected()
            case .edit:
                self?.optionEditSelected()
            case .delete:
                self?.optionDeleteSelected()
            }
            self?.methodUsageModeStackView.layoutIfNeeded()
            self?.paymentOperationStackView.layoutIfNeeded()
            self?.paymentCardStackView.layoutIfNeeded()
        },
                       completion: nil)
    }
    
    private func optionTokenizeSelected(){
        methodUsageModeTextField.loadDropDownData(PaymentMethodUsageMode.allCases.map{ $0.rawValue})
        methodUsageModeTextField.text = PaymentMethodUsageMode.single.rawValue
        methodUsageModeStackView.isHidden = false
        paymentOperationStackView.isHidden = true
        paymentCardStackView.isHidden = false
    }
    
    private func optionEditSelected() {
        let methodUsageData = ["NONE"] + [PaymentMethodUsageMode.multiple.rawValue]
        methodUsageModeTextField.loadDropDownData(methodUsageData)
        methodUsageModeTextField.text = ""
        methodUsageModeStackView.isHidden = false
        paymentOperationStackView.isHidden = false
        paymentCardStackView.isHidden = false
    }
    
    private func optionDeleteSelected() {
        methodUsageModeStackView.isHidden = true
        paymentOperationStackView.isHidden = false
        paymentCardStackView.isHidden = true
    }
    
    private func onChangePaymentCard(name: String) {
        guard let paymentCard = PaymentCardModel.models.filter({ $0.name == name }).first else {
            return
        }
        cardNumberTextField.text = paymentCard.number
        expiryMonthTextField.text = paymentCard.month
        expiryYearTextField.text = paymentCard.year
        cvnTextField.text = paymentCard.cvv
    }
}
