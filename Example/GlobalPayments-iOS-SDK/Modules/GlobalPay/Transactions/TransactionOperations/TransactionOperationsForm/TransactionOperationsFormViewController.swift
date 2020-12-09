import UIKit
import GlobalPayments_iOS_SDK

protocol TransactionOperationsFormDelegate: class {
    func onSubmitForm(form: TransactionOperationsForm)
}

final class TransactionOperationsFormViewController: UIViewController, StoryboardInstantiable {

    static var storyboardName = "Transactions"
    private let defaultAmount = "15.99"

    @IBOutlet private weak var navigationBar: UINavigationBar!
    @IBOutlet private weak var submitButton: UIButton!
    @IBOutlet private weak var paymentCardLabel: UILabel!
    @IBOutlet private weak var paymentCardTextField: UITextField!
    @IBOutlet private weak var cardNumberLabel: UILabel!
    @IBOutlet private weak var cardNumberTextField: UITextField!
    @IBOutlet private weak var expiryMonthLabel: UILabel!
    @IBOutlet private weak var expiryMonthTextField: UITextField!
    @IBOutlet private weak var expiryYearLabel: UILabel!
    @IBOutlet private weak var expiryYearTextField: UITextField!
    @IBOutlet private weak var cvvLabel: UILabel!
    @IBOutlet private weak var cvvTextField: UITextField!
    @IBOutlet private weak var transactionDataLabel: UILabel!
    @IBOutlet private weak var amountLabel: UILabel!
    @IBOutlet private weak var amountTextField: UITextField!
    @IBOutlet private weak var currencyLabel: UILabel!
    @IBOutlet private weak var currencyTextField: UITextField!
    @IBOutlet private weak var transactionTypeLabel: UILabel!
    @IBOutlet private weak var transactionTypeTextField: UITextField!

    weak var delegate: TransactionOperationsFormDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
    }

    private func setupUI() {
        hideKeyboardWhenTappedAround()
        navigationBar.topItem?.title = "transactoin.operations.form.title".localized()
        submitButton.apply(style: .globalPayStyle, title: "transactoin.operations.form.submit".localized())
        paymentCardLabel.text = "transactoin.operations.form.payment.card".localized()
        paymentCardTextField.loadDropDownData(PaymentCardModel.models.map { $0.name }, onSelectItem: onChangePaymentCard)
        cardNumberLabel.text = "transactoin.operations.form.card.number".localized()
        expiryMonthLabel.text = "transactoin.operations.form.expiry.month".localized()
        expiryYearLabel.text = "transactoin.operations.form.expiry.year".localized()
        cvvLabel.text = "transactoin.operations.form.cvn.cvv".localized()
        transactionDataLabel.text = "transactoin.operations.form.transaction.data".localized()
        amountLabel.text = "transactoin.operations.form.amount".localized()
        amountTextField.text = defaultAmount
        currencyLabel.text = "transactoin.operations.form.currency".localized()
        currencyTextField.loadDropDownData(Currency.allCases.map { $0.rawValue })
        transactionTypeLabel.text = "transactoin.operations.form.transaction.type".localized()
        transactionTypeTextField.loadDropDownData(TransactionOperationType.allCases.map { $0.rawValue.uppercased() })
    }

    // MARK: - Actions

    @IBAction private func onCancelAction() {
        dismiss(animated: true, completion: nil)
    }

    @IBAction private func onSubmitAction() {
        guard let cardNumber = cardNumberTextField.text, !cardNumber.isEmpty else { return }
        guard let expiryMonth = expiryMonthTextField.text, !expiryMonth.isEmpty,
              let expiryMonthNumeric = Int(expiryMonth) else { return }
        guard let expiryYear = expiryYearTextField.text, !expiryYear.isEmpty,
              let expiryYearNumeric = Int(expiryYear) else { return }
        guard let cvv = cvvTextField.text, !cvv.isEmpty else { return }
        guard let currency = currencyTextField.text, !currency.isEmpty else { return }
        guard let transactionOperationType = TransactionOperationType(value: transactionTypeTextField.text?.lowercased()) else { return }

        let form = TransactionOperationsForm(
            cardNumber: cardNumber,
            expiryMonth: expiryMonthNumeric,
            expiryYear: expiryYearNumeric,
            cvv: cvv,
            amount: NSDecimalNumber(string: amountTextField.text),
            currency: currency,
            transactionOperationType: transactionOperationType
        )
        delegate?.onSubmitForm(form: form)
        dismiss(animated: true, completion: nil)
    }

    private func onChangePaymentCard(name: String) {
        guard let paymentCard = PaymentCardModel.models.filter({ $0.name == name }).first else {
            return
        }
        cardNumberTextField.text = paymentCard.number
        expiryMonthTextField.text = paymentCard.month
        expiryYearTextField.text = paymentCard.year
        cvvTextField.text = paymentCard.cvv
    }
}
