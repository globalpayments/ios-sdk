import UIKit
import GlobalPayments_iOS_SDK

protocol VerificationsFormDelegate: class {
    func onSubmitForm(_ form: VerificationsForm)
}

final class VerificationsFormViewController: UIViewController, StoryboardInstantiable {

    static var storyboardName = "Verifications"

    weak var delegate: VerificationsFormDelegate?

    @IBOutlet private weak var submitButton: UIButton!
    @IBOutlet private weak var transactionDataLabel: UILabel!
    @IBOutlet private weak var referenceLabel: UILabel!
    @IBOutlet private weak var referenceTextField: UITextField!
    @IBOutlet private weak var currencyLabel: UILabel!
    @IBOutlet private weak var currencyTextField: UITextField!
    @IBOutlet private weak var countryLabel: UILabel!
    @IBOutlet private weak var countryTextField: UITextField!
    @IBOutlet private weak var paymentMethodLabel: UILabel!
    @IBOutlet private weak var idLabel: UILabel!
    @IBOutlet private weak var idTextField: UITextField!
    @IBOutlet private weak var firstNameLabel: UILabel!
    @IBOutlet private weak var firstNameTextField: UITextField!
    @IBOutlet private weak var lastNameLabel: UILabel!
    @IBOutlet private weak var lastNameTextField: UITextField!
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
    @IBOutlet private weak var avsAddressLabel: UILabel!
    @IBOutlet private weak var avsAddressTextField: UITextField!
    @IBOutlet private weak var avsPostalCodeLabel: UILabel!
    @IBOutlet private weak var avsPostalCodeTextField: UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
    }

    private func setupUI() {
        title = "verifications.form.title".localized()
        navigationItem.rightBarButtonItem = NavigationItems.cancel(self, #selector(onCancelAction)).button
        submitButton.apply(style: .globalPayStyle, title: "verifications.form.submit".localized())
        transactionDataLabel.text = "verifications.form.transaction.data".localized()
        referenceLabel.text = "verifications.form.reference".localized()
        referenceTextField.placeholder = "generic.empty".localized()
        currencyLabel.text = "verifications.form.currency".localized()
        currencyTextField.loadDropDownData(["USD", "CAD", "SBD", "EUR", "JPY"])
        countryLabel.text = "verifications.form.country".localized()
        countryTextField.placeholder = "generic.empty".localized()
        paymentMethodLabel.text = "verifications.form.payment.method".localized()
        idLabel.text = "verifications.form.id".localized()
        idTextField.placeholder = "generic.empty".localized()
        firstNameLabel.text = "verifications.form.first.name".localized()
        firstNameTextField.placeholder = "generic.empty".localized()
        lastNameLabel.text = "verifications.form.last.name".localized()
        lastNameTextField.placeholder = "generic.empty".localized()
        paymentCardLabel.text = "verifications.form.payment.card".localized()
        paymentCardTextField.loadDropDownData(PaymentCardModel.models.map { $0.name }, onSelectItem: onChangePaymentCard)
        cardNumberLabel.text = "verifications.form.card.number".localized()
        expiryMonthLabel.text = "verifications.form.expiry.month".localized()
        expiryYearLabel.text = "verifications.form.expiry.year".localized()
        cvnLabel.text = "verifications.form.cvn".localized()
        avsAddressLabel.text = "verifications.form.avs.address".localized()
        avsAddressTextField.placeholder = "generic.empty".localized()
        avsPostalCodeLabel.text = "verifications.form.avs.postal.code".localized()
        avsPostalCodeTextField.placeholder = "generic.empty".localized()
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

    // MARK: - Actions

    @IBAction private func onCancelAction() {
        dismiss(animated: true, completion: nil)
    }

    @IBAction private func onSubmitAction() {
        guard let currency = currencyTextField.text, !currency.isEmpty else { return }
        guard let cardNumber = cardNumberTextField.text, !cardNumber.isEmpty else { return }
        guard let expiryMonthValue = expiryMonthTextField.text, let expiryMonth = Int(expiryMonthValue) else { return }
        guard let expiryYearValue = expiryYearTextField.text, let expiryYear = Int(expiryYearValue) else { return }
        guard let cvn = cvnTextField.text, !cvn.isEmpty else { return }
        guard let country = countryTextField.text, !country.isEmpty else {
            showAlert(message: "verificatoins.form.missing.country".localized())
            return
        }

        let form = VerificationsForm(
            reference: referenceTextField.text,
            currency: currency,
            country: countryTextField.text,
            id: idTextField.text,
            firstName: firstNameTextField.text,
            lastName: lastNameTextField.text,
            cardNumber: cardNumber,
            expiryMonth: expiryMonth,
            expiryYear: expiryYear,
            cvn: cvn,
            avsAddress: avsAddressTextField.text,
            avsPostalCode: avsPostalCodeTextField.text
        )

        delegate?.onSubmitForm(form)
        dismiss(animated: true, completion: nil)
    }
}
