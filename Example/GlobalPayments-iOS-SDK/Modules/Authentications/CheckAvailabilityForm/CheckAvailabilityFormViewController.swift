import UIKit
import GlobalPayments_iOS_SDK

protocol CheckAvailabilityFormDelegate: AnyObject {
    func onSubmitForm(form: CheckAvailabilityForm)
}

final class CheckAvailabilityFormViewController: UIViewController, StoryboardInstantiable {

    static var storyboardName = "Authentications"

    weak var delegate: CheckAvailabilityFormDelegate?

    @IBOutlet private weak var paymentCardLabel: UILabel!
    @IBOutlet private weak var paymentCardTextField: UITextField!
    @IBOutlet private weak var cardNumberLabel: UILabel!
    @IBOutlet private weak var cardNumberTextField: UITextField!
    @IBOutlet private weak var authSourceLabel: UILabel!
    @IBOutlet private weak var authSourceTextField: UITextField!
    @IBOutlet private weak var expiryMonthLabel: UILabel!
    @IBOutlet private weak var expiryMonthTextField: UITextField!
    @IBOutlet private weak var expiryYearLabel: UILabel!
    @IBOutlet private weak var expiryYearTextField: UITextField!
    @IBOutlet private weak var cardHolderNameLabel: UILabel!
    @IBOutlet private weak var cardHolderNameTextField: UITextField!
    @IBOutlet private weak var transactionDataLabel: UILabel!
    @IBOutlet private weak var amountLabel: UILabel!
    @IBOutlet private weak var amountTextField: UITextField!
    @IBOutlet private weak var currencyLabel: UILabel!
    @IBOutlet private weak var currencyTextField: UITextField!
    @IBOutlet private weak var submitButton: UIButton!

    private let defaultAmount = "15.99"

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }

    private func setupUI() {
        title = "check.availability.form.title".localized()
        navigationItem.rightBarButtonItem = NavigationItems.cancel(self, #selector(onCancelAction)).button

        paymentCardLabel.text = "check.availability.form.payment.card".localized()
        paymentCardTextField.loadDropDownData(PaymentCardModel.modelsWith3ds.map { $0.name }, onSelectItem: onChangePaymentCard)
        cardNumberLabel.text = "check.availability.form.card.number".localized()
        authSourceLabel.text = "initiate.form.auth.source".localized()
        authSourceTextField.loadDropDownData(AuthenticationSource.allCases.map { $0.rawValue })
        expiryMonthLabel.text = "check.availability.form.expiry.month".localized()
        expiryYearLabel.text = "check.availability.form.expiry.year".localized()
        cardHolderNameLabel.text = "check.availability.form.card.holder.name".localized()
        cardHolderNameTextField.text = "John Smith"
        transactionDataLabel.text = "check.availability.form.transaction.data".localized()
        amountLabel.text = "check.availability.form.amount".localized()
        amountTextField.text = defaultAmount
        currencyLabel.text = "check.availability.form.currency".localized()
        currencyTextField.loadDropDownData(Currency.allCases.map { $0.rawValue })
        submitButton.apply(style: .globalPayStyle, title: "generic.submit".localized())
    }

    // MARK: - Actions

    @objc private func onCancelAction() {
        dismiss(animated: true, completion: nil)
    }

    @IBAction func onSubmitAction() {
        guard let cardNumber = cardNumberTextField.text, !cardNumber.isEmpty else { return }
        guard let expiryMonth = expiryMonthTextField.text, !expiryMonth.isEmpty,
              let expiryMonthNumeric = Int(expiryMonth) else { return }
        guard let expiryYear = expiryYearTextField.text, !expiryYear.isEmpty,
              let expiryYearNumeric = Int(expiryYear) else { return }
        guard let authSource = AuthenticationSource(value: authSourceTextField.text) else { return }
        guard let cardHolderName = cardHolderNameTextField.text, !cardHolderName.isEmpty else { return }
        guard let currency = currencyTextField.text, !currency.isEmpty else { return }

        let card = CreditCardData()
        card.number = cardNumber
        card.expMonth = expiryMonthNumeric
        card.expYear = expiryYearNumeric
        card.cardHolderName = cardHolderName

        let form = CheckAvailabilityForm(
            card: card,
            authSource: authSource,
            amount: NSDecimalNumber(string: amountTextField.text),
            currency: currency
        )
        delegate?.onSubmitForm(form: form)
        dismiss(animated: true, completion: nil)
    }

    private func onChangePaymentCard(name: String) {
        guard let paymentCard = PaymentCardModel.modelsWith3ds.filter({ $0.name == name }).first else {
            return
        }
        cardNumberTextField.text = paymentCard.number
        expiryMonthTextField.text = paymentCard.month
        expiryYearTextField.text = paymentCard.year
    }
}
