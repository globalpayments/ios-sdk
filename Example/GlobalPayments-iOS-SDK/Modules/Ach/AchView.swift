import UIKit
import GlobalPayments_iOS_SDK

protocol AchViewDelegate: AnyObject {
    func onChargePressed()
    func onRefundPressed()
    func fieldDataChanged(value: String, type: GpFieldsEnum)
}

class AchView: GpBaseView {
    
    private let defaultAmount = "10.00"
    
    private struct DimensKeys {
        static let marginTop: CGFloat = 20
        static let marginSide: CGFloat = 20
        static let marginSmall: CGFloat = 5
        static let marginMedium: CGFloat = 15
        static let disabledButton: CGFloat = 0.3
        static let enabledButton: CGFloat = 1.0
        static let buttonSize: CGFloat = 48.0
    }
    
    weak var delegate: AchViewDelegate?
    
    private lazy var scrollContainerView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.showsVerticalScrollIndicator = false
        return scrollView
    }()
    
    private lazy var containerView: UIView = {
        let containerView = UIView()
        containerView.translatesAutoresizingMaskIntoConstraints = false
        return containerView
    }()
    
    private lazy var amountFieldView: GpTextFieldView = {
        let field = GpTextFieldView()
        field.titleMandatory = "hosted.fields.payment.amount.title".localized()
        field.delegate = self
        field.tagField = .amount
        field.inputMode = .decimalPad
        field.currency = "$"
        field.translatesAutoresizingMaskIntoConstraints = false
        return field
    }()
    
    private lazy var bankDetailsTitle: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Bank Details"
        label.font = .boldSystemFont(ofSize: 20)
        label.textColor = #colorLiteral(red: 0, green: 0.3087183237, blue: 0.5186551213, alpha: 1)
        return label
    }()
    
    private lazy var accountHolderField: GpTextFieldView = {
        let field = GpTextFieldView()
        field.title = "Account Holder Name"
        field.tagField = .accountHolderName
        field.delegate = self
        field.translatesAutoresizingMaskIntoConstraints = false
        return field
    }()
    
    private lazy var accountTypeSecCodeFieldsView: GpDoubleFieldView = {
        let fields = GpDoubleFieldView()
        fields.translatesAutoresizingMaskIntoConstraints = false
        fields.firstTitle = "Account Type"
        fields.secondTitle = "Sec Code"
        fields.setFirstTagField(.accountType, delegate: self)
        fields.setSecondTagField(.secCode, delegate: self)
        fields.setDropDownBoth( AccountType.allCases.map { $0.rawValue.uppercased() }, secondData: SecCode.allCases.map { $0.rawValue.uppercased() } )
        return fields
    }()
    
    private lazy var routingAccountNumberFieldsView: GpDoubleFieldView = {
        let fields = GpDoubleFieldView()
        fields.translatesAutoresizingMaskIntoConstraints = false
        fields.firstTitle = "Routing Number"
        fields.secondTitle = "Account Number"
        fields.setFirstTagField(.routingNumber, delegate: self)
        fields.setSecondTagField(.accountNumber, delegate: self)
        return fields
    }()
    
    private lazy var customerDetailsTitle: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Customer Details"
        label.font = .boldSystemFont(ofSize: 20)
        label.textColor = #colorLiteral(red: 0, green: 0.3087183237, blue: 0.5186551213, alpha: 1)
        return label
    }()
    
    private lazy var firstLastNameFieldsView: GpDoubleFieldView = {
        let fields = GpDoubleFieldView()
        fields.translatesAutoresizingMaskIntoConstraints = false
        fields.firstTitle = "First Name"
        fields.secondTitle = "Last Name"
        fields.setFirstTagField(.firstName, delegate: self)
        fields.setSecondTagField(.lastName, delegate: self)
        return fields
    }()
    
    private lazy var dobFieldView: GpTextFieldView = {
        let field = GpTextFieldView()
        field.title = "Date of Birth"
        field.delegate = self
        field.tagField = .dateOfBirth
        field.translatesAutoresizingMaskIntoConstraints = false
        return field
    }()
    
    private lazy var mobileHomePhoneFieldsView: GpDoubleFieldView = {
        let fields = GpDoubleFieldView()
        fields.translatesAutoresizingMaskIntoConstraints = false
        fields.firstTitle = "Mobile Phone"
        fields.secondTitle = "Home Phone"
        fields.setFirstTagField(.mobilePhone, delegate: self)
        fields.setSecondTagField(.homePhone, delegate: self)
        return fields
    }()
    
    private lazy var billingAddressTitle: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Billing Address"
        label.font = .boldSystemFont(ofSize: 20)
        label.textColor = #colorLiteral(red: 0, green: 0.3087183237, blue: 0.5186551213, alpha: 1)
        return label
    }()
    
    private lazy var line1FieldView: GpTextFieldView = {
        let field = GpTextFieldView()
        field.title = "Line 1"
        field.delegate = self
        field.tagField = .line1
        field.translatesAutoresizingMaskIntoConstraints = false
        return field
    }()
    
    private lazy var line2FieldView: GpTextFieldView = {
        let field = GpTextFieldView()
        field.title = "Line 2"
        field.delegate = self
        field.tagField = .line2
        field.translatesAutoresizingMaskIntoConstraints = false
        return field
    }()
    
    private lazy var cityStateFieldsView: GpDoubleFieldView = {
        let fields = GpDoubleFieldView()
        fields.translatesAutoresizingMaskIntoConstraints = false
        fields.firstTitle = "City:"
        fields.secondTitle = "State:"
        fields.setFirstTagField(.city, delegate: self)
        fields.setSecondTagField(.state, delegate: self)
        return fields
    }()
    
    private lazy var postalCountryFieldsView: GpDoubleFieldView = {
        let fields = GpDoubleFieldView()
        fields.translatesAutoresizingMaskIntoConstraints = false
        fields.firstTitle = "Postal code:"
        fields.secondTitle = "Country:"
        fields.setFirstTagField(.postalCode, delegate: self)
        fields.setSecondTagField(.country, delegate: self)
        return fields
    }()
    
    private lazy var chargeButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.applyWithImage(style: .redesignStyle, title: "ach.charge".localized())
        button.addTarget(self, action: #selector(chargeButtonPressed), for: .touchUpInside)
        return button
    }()
    
    private lazy var refundButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.applyFlat(style: .redesignStyle, title: "ach.refund".localized())
        button.addTarget(self, action: #selector(refundButtonPressed), for: .touchUpInside)
        return button
    }()
    
    override init() {
        super.init()
        title = "globalpay.ach.configuration.title".localized()
        setUpScrollContainerViewConstraints()
        setUpAmountFieldConstraints()
        setUpBankDetailsConstraints()
        setUpCustomerDetailsConstraints()
        setUpBillingAddressConstraints()
        setUpChargeButtonConstraints()
        setUpRefundButtonConstraints()
        
        setUpSeparatorBottomLineConstraints(containerView, belowView: refundButton)
        setUpCodeResponseViewConstraints(containerView)
        setUpDataExampleCode()
        
        setUpLoadingViewConstraints()
    }
    
    private func setUpDataExampleCode() {
        codeResponseView.locationLabel = "Modules/Ach/"
        codeResponseView.fileLabel = "AchViewModel.swift"
        codeResponseView.titleResponseDataView = "AchInfo"
        codeResponseView.exampleCodeImage = #imageLiteral(resourceName: "ach_code")
    }
    
    private func setUpScrollContainerViewConstraints() {
        addSubview(scrollContainerView)
        scrollContainerView.addSubview(containerView)
        NSLayoutConstraint.activating([
            scrollContainerView.relativeTo(separatorLineView, positioned: .belowWidth(spacing: DimensKeys.marginMedium)),
            scrollContainerView.relativeTo(self, positioned: .safeBottom()),
            containerView.relativeTo(scrollContainerView, positioned: .width() + .top() + .centerX() + .bottom())
        ])
    }
    
    private func setUpAmountFieldConstraints() {
        containerView.addSubview(amountFieldView)
        NSLayoutConstraint.activating([
            amountFieldView.relativeTo(containerView, positioned: .top() + .width())
        ])
    }
    
    private func setUpBankDetailsConstraints() {
        containerView.addSubview(bankDetailsTitle)
        containerView.addSubview(accountHolderField)
        containerView.addSubview(accountTypeSecCodeFieldsView)
        containerView.addSubview(routingAccountNumberFieldsView)
        NSLayoutConstraint.activating([
            bankDetailsTitle.relativeTo(amountFieldView, positioned: .belowWidth(spacing: DimensKeys.marginMedium)),
            accountHolderField.relativeTo(bankDetailsTitle, positioned: .belowWidth(spacing: DimensKeys.marginMedium)),
            accountTypeSecCodeFieldsView.relativeTo(accountHolderField, positioned: .belowWidth(spacing: DimensKeys.marginMedium)),
            routingAccountNumberFieldsView.relativeTo(accountTypeSecCodeFieldsView, positioned: .belowWidth(spacing: DimensKeys.marginMedium))
        ])
    }
    
    private func setUpCustomerDetailsConstraints() {
        containerView.addSubview(customerDetailsTitle)
        containerView.addSubview(firstLastNameFieldsView)
        containerView.addSubview(dobFieldView)
        containerView.addSubview(mobileHomePhoneFieldsView)
        NSLayoutConstraint.activating([
            customerDetailsTitle.relativeTo(routingAccountNumberFieldsView, positioned: .belowWidth(spacing: DimensKeys.marginMedium)),
            firstLastNameFieldsView.relativeTo(customerDetailsTitle, positioned: .belowWidth(spacing: DimensKeys.marginMedium)),
            dobFieldView.relativeTo(firstLastNameFieldsView, positioned: .belowWidth(spacing: DimensKeys.marginMedium)),
            mobileHomePhoneFieldsView.relativeTo(dobFieldView, positioned: .belowWidth(spacing: DimensKeys.marginMedium))
        ])
    }
    
    private func setUpBillingAddressConstraints() {
        containerView.addSubview(billingAddressTitle)
        containerView.addSubview(line1FieldView)
        containerView.addSubview(line2FieldView)
        containerView.addSubview(cityStateFieldsView)
        containerView.addSubview(postalCountryFieldsView)
        NSLayoutConstraint.activating([
            billingAddressTitle.relativeTo(mobileHomePhoneFieldsView, positioned: .belowWidth(spacing: DimensKeys.marginMedium)),
            line1FieldView.relativeTo(billingAddressTitle, positioned: .belowWidth(spacing: DimensKeys.marginMedium)),
            line2FieldView.relativeTo(line1FieldView, positioned: .belowWidth(spacing: DimensKeys.marginMedium)),
            cityStateFieldsView.relativeTo(line2FieldView, positioned: .belowWidth(spacing: DimensKeys.marginMedium)),
            postalCountryFieldsView.relativeTo(cityStateFieldsView, positioned: .belowWidth(spacing: DimensKeys.marginMedium))
        ])
    }
    
    private func setUpChargeButtonConstraints() {
        containerView.addSubview(chargeButton)
        NSLayoutConstraint.activating([
            chargeButton.relativeTo(postalCountryFieldsView, positioned: .belowWidth(spacing: DimensKeys.marginMedium)),
            chargeButton.constrainedBy(.constantHeight(DimensKeys.buttonSize))
        ])
    }
    
    private func setUpRefundButtonConstraints() {
        containerView.addSubview(refundButton)
        NSLayoutConstraint.activating([
            refundButton.relativeTo(chargeButton, positioned: .belowWidth(spacing: DimensKeys.marginMedium)),
            refundButton.constrainedBy(.constantHeight(DimensKeys.buttonSize))
        ])
    }
    
    func defaultValues() {
        amountFieldView.text = defaultAmount
        // BankDetails
        accountHolderField.text = "Jane Doe"
        accountTypeSecCodeFieldsView.firstText = AccountType.saving.mapped(for: .gpApi)
        accountTypeSecCodeFieldsView.secondText = SecCode.web.mapped(for: .gpApi)
        routingAccountNumberFieldsView.firstText = "122000030"
        routingAccountNumberFieldsView.secondText = "1234567890"

        // CustomerDetails
        firstLastNameFieldsView.firstText = "James"
        firstLastNameFieldsView.secondText = "Mason"
        dobFieldView.text = "1980-01-01"
        mobileHomePhoneFieldsView.firstText = "+35312345678"
        mobileHomePhoneFieldsView.secondText = "+11234589"

        // BillingAddress
        line1FieldView.text = "12000 Smoketown Rd"
        line2FieldView.text = "Apt 3B"
        cityStateFieldsView.firstText = "Mesa"
        cityStateFieldsView.secondText = "AZ"
        postalCountryFieldsView.firstText = "22192"
        postalCountryFieldsView.secondText = "US"
    }
    
    @objc func chargeButtonPressed() {
        delegate?.onChargePressed()
    }
    
    @objc func refundButtonPressed() {
        delegate?.onRefundPressed()
    }
    
    func enableButton(_ enable: Bool) {
        chargeButton.isEnabled = enable
        chargeButton.alpha = enable ? DimensKeys.enabledButton : DimensKeys.disabledButton
    }
    
    func toBottomView() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.moveToBottomView()
        }
    }
    
    private func moveToBottomView() {
        let bottomOffset = CGPoint(x: 0, y: scrollContainerView.contentSize.height - scrollContainerView.bounds.height + scrollContainerView.contentInset.bottom)
        scrollContainerView.setContentOffset(bottomOffset, animated: true)
    }
}

extension AchView: GpTextFieldDelegate {
    
    func textChanged(value: String, type: GpFieldsEnum) {
        delegate?.fieldDataChanged(value: value, type: type)
    }
}

