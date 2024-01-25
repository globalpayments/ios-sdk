import UIKit
import GlobalPayments_iOS_SDK

protocol AchChargeFormDelegate: AnyObject {
    func onSubmitForm(form: AchChargeForm, path: TransactionTypePath)
}

final class AchChargeFormViewController: UIViewController, StoryboardInstantiable {

    static let storyboardName = "Ach"
    weak var delegate: AchChargeFormDelegate?
    private let defaultAmount = "10.00"

    var path: TransactionTypePath = .charge

    @IBOutlet weak var amountTexField: UITextField!
    @IBOutlet weak var currencyTextField: UITextField!

    // BankDetails
    @IBOutlet weak var accountHolderNameTextField: UITextField!
    @IBOutlet weak var accountTypeTextField: UITextField!
    @IBOutlet weak var secCodeTextField: UITextField!
    @IBOutlet weak var routingNumberTextField: UITextField!
    @IBOutlet weak var accountNumberTextField: UITextField!

    // CustomerDetails
    @IBOutlet weak var firstNameTextField: UITextField!
    @IBOutlet weak var lastNameTextField: UITextField!
    @IBOutlet weak var birthDateTextField: UITextField!
    @IBOutlet weak var mobilePhoneTextField: UITextField!
    @IBOutlet weak var homePhoneTextField: UITextField!

    // BillingAddress
    @IBOutlet weak var line1TextField: UITextField!
    @IBOutlet weak var line2TextField: UITextField!
    @IBOutlet weak var cityTextField: UITextField!
    @IBOutlet weak var stateTextField: UITextField!
    @IBOutlet weak var postalCodeTextField: UITextField!
    @IBOutlet weak var countryTextField: UITextField!

    @IBOutlet private weak var submitButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setMockData()
    }

    private func setupUI() {
        hideKeyboardWhenTappedAround()
        title = path == .charge ? "ach.charge".localized() : "ach.refund".localized()
        navigationItem.rightBarButtonItem = NavigationItems.cancel(self, #selector(onCancelAction)).button
        submitButton.apply(style: .globalPayStyle, title: "dispute.document.form.submit".localized())

        accountTypeTextField.loadDropDownData(AccountType.allCases.map { $0.rawValue.uppercased() })
        secCodeTextField.loadDropDownData(SecCode.allCases.map { $0.rawValue.uppercased() })
        countryTextField.loadDropDownData(CountryUtils.ISOCountryInfo.allCountries.map({ $0.alpha2}))
        currencyTextField.loadDropDownData(Currency.allCases.map { $0.rawValue })
    }

    private func setMockData() {
        amountTexField.text = defaultAmount

        // BankDetails
        accountHolderNameTextField.text = "Jane Doe"
        accountTypeTextField.text = AccountType.saving.mapped(for: .gpApi)
        secCodeTextField.text = SecCode.web.mapped(for: .gpApi)
        routingNumberTextField.text = "122000030"
        accountNumberTextField.text = "1234567890"

        // CustomerDetails
        firstNameTextField.text = "James"
        lastNameTextField.text = "Mason"
        birthDateTextField.text = "1980-01-01"
        mobilePhoneTextField.text = "+35312345678"
        homePhoneTextField.text = "+11234589"

        // BillingAddress
        line1TextField.text = "12000 Smoketown Rd"
        line2TextField.text = "Apt 3B"
        cityTextField.text = "Mesa"
        postalCodeTextField.text = "22192"
        stateTextField.text = "AZ"
        countryTextField.text = "US"
    }

    // MARK: - Actions

    @objc private func onCancelAction() {
        dismiss(animated: true, completion: nil)
    }

    @IBAction private func onSubmitAction() {
        guard let amount = amountTexField.text, let currency = currencyTextField.text else { return }

        guard let holderName = accountHolderNameTextField.text, let accountType = accountTypeTextField.text, let secCode = secCodeTextField.text, let routingNumber = routingNumberTextField.text, let accountNumber = accountNumberTextField.text else { return }

        let bankDetails = AchBankDetailsForm(
            accountHolderName: holderName,
            accountType: accountType,
            secCode: secCode,
            routingNumber: routingNumber,
            accountNumber: accountNumber)

        guard let firstName = firstNameTextField.text, let lastName = lastNameTextField.text, let birthDate = birthDateTextField.text, let mobilePhone = mobilePhoneTextField.text, let homePhone = homePhoneTextField.text else { return }

        let customerDetails = AchCustomerDetailsForm(
            firstName: firstName,
            lastName: lastName,
            birthDate: birthDate,
            mobilePhone: mobilePhone,
            homePhone: homePhone)

        guard let line1 = line1TextField.text, let line2 = line2TextField.text, let city = cityTextField.text, let state = stateTextField.text, let postalCode = postalCodeTextField.text, let country = countryTextField.text else { return }

        let billingAddress = AchBillingAddressForm(
            line1: line1,
            line2: line2,
            city: city,
            state: state,
            postalCode: postalCode,
            country: country)

        let form = AchChargeForm(
            amount: NSDecimalNumber(string: amount),
            currency: currency,
            bankDetails: bankDetails,
            customerDetails: customerDetails,
            billingAddress: billingAddress)

        delegate?.onSubmitForm(form: form, path: path)
        dismiss(animated: true, completion: nil)
    }
}
