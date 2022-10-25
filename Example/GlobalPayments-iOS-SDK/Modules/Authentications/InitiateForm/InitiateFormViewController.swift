import UIKit
import GlobalPayments_iOS_SDK

protocol InitiateFormDelegate: class {
    func onSubmitForm(form: InitiateForm, flowType: FlowType)
}

final class InitiateFormViewController: UIViewController, StoryboardInstantiable {

    static var storyboardName = "Authentications"

    weak var delegate: InitiateFormDelegate?
    var flowType: FlowType = .initiate

    // Card
    @IBOutlet private weak var paymentCardLabel: UILabel!
    @IBOutlet private weak var paymentCardTextField: UITextField!
    @IBOutlet private weak var cardNumberLabel: UILabel!
    @IBOutlet private weak var cardNumberTextField: UITextField!
    @IBOutlet private weak var expMonthLabel: UILabel!
    @IBOutlet private weak var expMonthTextField: UITextField!
    @IBOutlet private weak var expYearLabel: UILabel!
    @IBOutlet private weak var expYearTextField: UITextField!
    @IBOutlet private weak var cardHolderNameLabel: UILabel!
    @IBOutlet private weak var cardHolderNameTextField: UITextField!
    // General
    @IBOutlet private weak var amountLabel: UILabel!
    @IBOutlet private weak var amountTextField: UITextField!
    @IBOutlet private weak var currencyLabel: UILabel!
    @IBOutlet private weak var currencyTextField: UITextField!
    @IBOutlet private weak var methodCompletionLabel: UILabel!
    @IBOutlet private weak var methodCompletionTextField: UITextField!
    @IBOutlet private weak var authSourceLabel: UILabel!
    @IBOutlet private weak var authSourceTextField: UITextField!
    @IBOutlet private weak var orderCreateDateLabel: UILabel!
    @IBOutlet private weak var orderCreateDateTextField: UITextField!
    // Billing
    @IBOutlet private weak var billingAddress1Label: UILabel!
    @IBOutlet private weak var billingAddress1TextField: UITextField!
    @IBOutlet private weak var billingAddress2Label: UILabel!
    @IBOutlet private weak var billingAddress2TextField: UITextField!
    @IBOutlet private weak var billingAddress3Label: UILabel!
    @IBOutlet private weak var billingAddress3TextField: UITextField!
    @IBOutlet private weak var billingCityLabel: UILabel!
    @IBOutlet private weak var billingCityTextField: UITextField!
    @IBOutlet private weak var billingPostalCodeLabel: UILabel!
    @IBOutlet private weak var billingPostalCodeTextField: UITextField!
    @IBOutlet private weak var billingCountryCodeLabel: UILabel!
    @IBOutlet private weak var billingCountryCodeTextField: UITextField!
    // Shipping
    @IBOutlet private weak var shippingAddress1Label: UILabel!
    @IBOutlet private weak var shippingAddress1TextField: UITextField!
    @IBOutlet private weak var shippingAddress2Label: UILabel!
    @IBOutlet private weak var shippingAddress2TextField: UITextField!
    @IBOutlet private weak var shippingAddress3Label: UILabel!
    @IBOutlet private weak var shippingAddress3TextField: UITextField!
    @IBOutlet private weak var shippingCityLabel: UILabel!
    @IBOutlet private weak var shippingCityTextField: UITextField!
    @IBOutlet private weak var shippingPostalCodeLabel: UILabel!
    @IBOutlet private weak var shippingPostalCodeTextField: UITextField!
    @IBOutlet private weak var shippingCountryCodeLabel: UILabel!
    @IBOutlet private weak var shippingCountryCodeTextField: UITextField!
    // Browser data
    @IBOutlet private weak var acceptHeaderLabel: UILabel!
    @IBOutlet private weak var acceptHeaderTextField: UITextField!
    @IBOutlet private weak var colorDepthLabel: UILabel!
    @IBOutlet private weak var colorDepthTextField: UITextField!
    @IBOutlet private weak var ipAddressLabel: UILabel!
    @IBOutlet private weak var ipAddressTextField: UITextField!
    @IBOutlet private weak var javaEnabledLabel: UILabel!
    @IBOutlet private weak var javaEnabledSwitch: UISwitch!
    @IBOutlet private weak var jsEnabledLabel: UILabel!
    @IBOutlet private weak var jsEnabledSwitch: UISwitch!
    @IBOutlet private weak var languageLabel: UILabel!
    @IBOutlet private weak var languageTextField: UITextField!
    @IBOutlet private weak var screenHeightLabel: UILabel!
    @IBOutlet private weak var screenHeightTextField: UITextField!
    @IBOutlet private weak var screenWidthLabel: UILabel!
    @IBOutlet private weak var screenWidthTextField: UITextField!
    @IBOutlet private weak var challengeWindowSizeLabel: UILabel!
    @IBOutlet private weak var challengeWindowSizeTextField: UITextField!
    @IBOutlet private weak var timeZoneLabel: UILabel!
    @IBOutlet private weak var timeZoneTextField: UITextField!
    @IBOutlet private weak var userAgentLabel: UILabel!
    @IBOutlet private weak var userAgentTextField: UITextField!
    @IBOutlet private weak var submitButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
    }

    private func setupUI() {
        switch flowType {
        case .initiate:
            title = "initiate.form.title".localized()
        case .full:
            title = "initiate.form.full.title".localized()
        }
        navigationItem.rightBarButtonItem = NavigationItems.cancel(self, #selector(onCancelAction)).button
        submitButton.apply(style: .globalPayStyle, title: "generic.submit".localized())
        // Card
        paymentCardLabel.text = "initiate.form.payment.card".localized()
        paymentCardTextField.loadDropDownData(PaymentCardModel.modelsWith3ds.map { $0.name }, onSelectItem: onChangePaymentCard)
        cardNumberLabel.text = "initiate.form.card.number".localized()
        expMonthLabel.text = "initiate.form.exp.month".localized()
        expYearLabel.text = "initiate.form.exp.year".localized()
        cardHolderNameLabel.text = "initiate.form.cardholder.name".localized()
        cardHolderNameTextField.text = "John Smith"
        // General
        amountLabel.text = "initiate.form.amount".localized()
        amountTextField.text = "15.99"
        currencyLabel.text = "initiate.form.currency".localized()
        currencyTextField.loadDropDownData(Currency.allCases.map { $0.rawValue })
        methodCompletionLabel.text = "initiate.form.method.url".localized()
        methodCompletionTextField.loadDropDownData(MethodUrlCompletion.allCases.map { $0.rawValue })
        authSourceLabel.text = "initiate.form.auth.source".localized()
        authSourceTextField.loadDropDownData(AuthenticationSource.allCases.map { $0.rawValue })
        orderCreateDateLabel.text = "initiate.form.order.date".localized()
        orderCreateDateTextField.loadDate()
        // Billing
        billingAddress1Label.text = "initiate.form.billing.address1".localized()
        billingAddress1TextField.text = "Flat 456"
        billingAddress2Label.text = "initiate.form.billing.address2".localized()
        billingAddress2TextField.text = "House 789"
        billingAddress3Label.text = "initiate.form.billing.address3".localized()
        billingAddress3TextField.text = "no"
        billingCityLabel.text = "initiate.form.billing.city".localized()
        billingCityTextField.text = "Halifax"
        billingPostalCodeLabel.text = "initiate.form.billing.postal.code".localized()
        billingPostalCodeTextField.text = "W5 9HR"
        billingCountryCodeLabel.text = "initiate.form.billing.country.code".localized()
        billingCountryCodeTextField.text = "826"
        // Shipping
        shippingAddress1Label.text = "initiate.form.shipping.address1".localized()
        shippingAddress1TextField.text = "Apartment 852"
        shippingAddress2Label.text = "initiate.form.shipping.address2".localized()
        shippingAddress2TextField.text = "Complex 741"
        shippingAddress3Label.text = "initiate.form.shipping.address3".localized()
        shippingAddress3TextField.text = "no"
        shippingCityLabel.text = "initiate.form.shipping.city".localized()
        shippingCityTextField.text = "Chicago"
        shippingPostalCodeLabel.text = "initiate.form.shipping.postal.code".localized()
        shippingPostalCodeTextField.text = "5001"
        shippingCountryCodeLabel.text = "initiate.form.shipping.country.code".localized()
        shippingCountryCodeTextField.text = "840"
        // Browser data
        acceptHeaderLabel.text = "initiate.form.accept.header".localized()
        acceptHeaderTextField.text = "text/html,application/xhtml+xml,application/xml;q=9,image/webp,img/apng,*/*;q=0.8"
        colorDepthLabel.text = "initiate.form.color.depth".localized()
        colorDepthTextField.loadDropDownData(BrowserData.ColorDepth.allCases.map { $0.rawValue })
        ipAddressLabel.text = "initiate.form.ip.address".localized()
        ipAddressTextField.text = "123.123.123.123"
        javaEnabledLabel.text = "initiate.form.java.enabled".localized()
        jsEnabledLabel.text = "initiate.form.js.enabled".localized()
        languageLabel.text = "initiate.form.language".localized()
        languageTextField.text = "en"
        screenHeightLabel.text = "initiate.form.screen.height".localized()
        screenHeightTextField.text = "\(Int(UIScreen.main.bounds.height))"
        screenWidthLabel.text = "initiate.form.screen.width".localized()
        screenWidthTextField.text = "\(Int(UIScreen.main.bounds.width))"
        challengeWindowSizeLabel.text = "initiate.form.window.size".localized()
        challengeWindowSizeTextField.loadDropDownData(BrowserData.ChallengeWindowSize.allCases.map { $0.rawValue })
        timeZoneLabel.text = "initiate.form.timezone".localized()
        timeZoneTextField.text = "0"
        userAgentLabel.text = "initiate.form.user.agent".localized()
        userAgentTextField.text = "Mozilla/5.0 (Windows NT 6.1; Win64, x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/70.0.3538.110 Safari/537.36"
    }

    // MARK: - Actions

    @objc private func onCancelAction() {
        dismiss(animated: true, completion: nil)
    }

    @IBAction private func onSubmitAction() {
        guard let expYear = expYearTextField.text, !expYear.isEmpty, let numericExpYear = Int(expYear) else { return }
        guard let expMonth = expMonthTextField.text, !expMonth.isEmpty, let numericExpMonth = Int(expMonth) else { return }
        guard let currency = currencyTextField.text, !currency.isEmpty else { return }
        guard let mehodCompletion = MethodUrlCompletion(value: methodCompletionTextField.text) else { return }
        guard let authSource = AuthenticationSource(value: authSourceTextField.text) else { return }
        guard let screenWidth = screenWidthLabel.text, !screenWidth.isEmpty else { return }
        guard let screenHeight = screenHeightLabel.text, !screenHeight.isEmpty else { return }

        let card = CreditCardData()
        card.number = cardNumberTextField.text
        card.expYear = numericExpYear
        card.expMonth = numericExpMonth
        card.cardHolderName = cardHolderNameTextField.text

        let shippingAddress = Address()
        shippingAddress.streetAddress1 = shippingAddress1TextField.text
        shippingAddress.streetAddress2 = shippingAddress2TextField.text
        shippingAddress.streetAddress3 = shippingAddress3TextField.text
        shippingAddress.city = shippingCityTextField.text
        shippingAddress.postalCode = shippingPostalCodeTextField.text
        shippingAddress.countryCode = shippingCountryCodeTextField.text

        let billingAddress = Address()
        billingAddress.streetAddress1 = billingAddress1TextField.text
        billingAddress.streetAddress2 = billingAddress2TextField.text
        billingAddress.streetAddress3 = billingAddress3TextField.text
        billingAddress.city = billingCityTextField.text
        billingAddress.postalCode = billingPostalCodeTextField.text
        billingAddress.countryCode = billingCountryCodeTextField.text

        let browserData = BrowserData()
        browserData.acceptHeader = acceptHeaderTextField.text
        browserData.colorDepth = BrowserData.ColorDepth(value: colorDepthTextField.text)
        browserData.ipAddress = ipAddressTextField.text
        browserData.javaEnabled = javaEnabledSwitch.isOn
        browserData.javaScriptEnabled = jsEnabledSwitch.isOn
        browserData.language = languageTextField.text
        browserData.screenHeight = Int(screenHeight)
        browserData.screenWidth = Int(screenWidth)
        browserData.challengeWindowSize = BrowserData.ChallengeWindowSize(value: challengeWindowSizeTextField.text)
        browserData.timezone = timeZoneTextField.text
        browserData.userAgent = userAgentTextField.text

        let form = InitiateForm(
            card: card,
            amount: NSDecimalNumber(string: amountTextField.text),
            currency: currency,
            mehodCompletion: mehodCompletion,
            authSource: authSource,
            createDate: orderCreateDateTextField.text?.formattedDate(),
            shippingAddress: shippingAddress,
            billingAddress: billingAddress,
            browserData: browserData
        )

        delegate?.onSubmitForm(form: form, flowType: flowType)
        dismiss(animated: true, completion: nil)
    }

    private func onChangePaymentCard(name: String) {
        guard let paymentCard = PaymentCardModel.modelsWith3ds.filter({ $0.name == name }).first else {
            return
        }
        cardNumberTextField.text = paymentCard.number
        expMonthTextField.text = paymentCard.month
        expYearTextField.text = paymentCard.year
    }
}
