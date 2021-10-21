import UIKit

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
        guard let cardNumber = cardNumberTextField.text,
              !cardNumber.isEmpty else {
            return
        }
        guard let cardExpiryMonthValue = expiryMonthTextField.text,
              let cardExpiryMonth = Int(cardExpiryMonthValue) else {
            return
        }
        guard let cardExpiryYearValue = expiryYearTextField.text,
              let cardExpiryYear = Int(cardExpiryYearValue) else {
            return
        }
        guard let cvn = cvnTextField.text,
              !cvn.isEmpty else {
            return
        }
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

        UIView.animate(withDuration: 0.5,
                       delay: 0.0,
                       usingSpringWithDamping: 0.9,
                       initialSpringVelocity: 1,
                       options: [],
                       animations: { [weak self] in
                        switch paymentOperation {
                        case .tokenize:
                            self?.paymentOperationStackView.isHidden = true
                            self?.paymentCardStackView.isHidden = false
                        case .edit:
                            self?.paymentOperationStackView.isHidden = false
                            self?.paymentCardStackView.isHidden = false
                        case .delete:
                            self?.paymentOperationStackView.isHidden = false
                            self?.paymentCardStackView.isHidden = true
                        }
                        self?.paymentOperationStackView.layoutIfNeeded()
                        self?.paymentCardStackView.layoutIfNeeded()
                       },
                       completion: nil)
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
