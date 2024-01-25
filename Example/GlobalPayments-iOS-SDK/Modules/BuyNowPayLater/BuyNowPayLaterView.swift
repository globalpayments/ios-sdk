import UIKit
import GlobalPayments_iOS_SDK

protocol BuyNowPayLaterViewDelegate: AnyObject {
    func onBnplPressed()
    func onProductsPressed()
    func onBillingPressed()
    func onShippingPressed()
    func onCustomerPressed()
    func fieldDataChanged(value: String, type: GpFieldsEnum)
}

class BuyNowPayLaterView: GpBaseView {
    
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
    
    weak var delegate: BuyNowPayLaterViewDelegate?
    
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
        field.titleMandatory = "hosted.fields.amount.authorize.title".localized()
        field.delegate = self
        field.tagField = .amount
        field.inputMode = .decimalPad
        field.currency = "$"
        field.translatesAutoresizingMaskIntoConstraints = false
        return field
    }()
    
    private lazy var accountTypeFieldView: GpTextFieldView = {
        let field = GpTextFieldView()
        field.title = "bnpl.account.type.title".localized()
        field.setDropDown(BNPLType.allCases.map { $0.mapped(for: .gpApi) ?? .empty})
        field.delegate = self
        field.tagField = .accountType
        field.translatesAutoresizingMaskIntoConstraints = false
        return field
    }()
    
    private lazy var productsFieldView: GpTextFieldView = {
        let field = GpTextFieldView()
        field.title = "bnpl.products.title".localized()
        field.delegate = self
        field.tagField = .amount
        field.onFieldClicked { self.delegate?.onProductsPressed() }
        field.translatesAutoresizingMaskIntoConstraints = false
        return field
    }()
    
    private lazy var billingAddressFieldView: GpTextFieldView = {
        let field = GpTextFieldView()
        field.title = "bnpl.billing.address.title".localized()
        field.delegate = self
        field.tagField = .billing
        field.onFieldClicked { self.delegate?.onBillingPressed() }
        field.translatesAutoresizingMaskIntoConstraints = false
        return field
    }()
    
    private lazy var shippingAddressFieldView: GpTextFieldView = {
        let field = GpTextFieldView()
        field.title = "bnpl.shipping.address.title".localized()
        field.delegate = self
        field.tagField = .shipping
        field.onFieldClicked { self.delegate?.onShippingPressed() }
        field.translatesAutoresizingMaskIntoConstraints = false
        return field
    }()
    
    private lazy var containerPhoneNumber: UIView = {
        let containerView = UIView()
        containerView.translatesAutoresizingMaskIntoConstraints = false
        return containerView
    }()
    
    private lazy var countryCodeFieldView: GpTextFieldView = {
        let field = GpTextFieldView()
        field.title = "transaction.report.by.id.country".localized()
        field.delegate = self
        field.inputMode = .numberPad
        field.tagField = .countryCode
        field.translatesAutoresizingMaskIntoConstraints = false
        return field
    }()
    
    private lazy var phoneNumberFieldView: GpTextFieldView = {
        let field = GpTextFieldView()
        field.title = "bnpl.shipping.phone.number.title".localized()
        field.delegate = self
        field.inputMode = .phonePad
        field.tagField = .phoneNumber
        field.translatesAutoresizingMaskIntoConstraints = false
        return field
    }()
    
    private lazy var phoneTypeFieldView: GpTextFieldView = {
        let field = GpTextFieldView()
        field.title = "transaction.report.by.id.type".localized()
        field.setDropDown(PhoneNumberType.allCases.map { $0.mapped(for: .gpApi) ?? .empty})
        field.delegate = self
        field.tagField = .phoneType
        field.translatesAutoresizingMaskIntoConstraints = false
        return field
    }()
    
    private lazy var customerFieldView: GpTextFieldView = {
        let field = GpTextFieldView()
        field.title = "customer.title".localized()
        field.delegate = self
        field.onFieldClicked { self.delegate?.onCustomerPressed() }
        field.translatesAutoresizingMaskIntoConstraints = false
        return field
    }()
    
    private lazy var bnplButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.applyWithImage(style: .redesignStyle, title: "buyNowPayLater.title".localized())
        button.addTarget(self, action: #selector(bnplButtonPressed), for: .touchUpInside)
        return button
    }()
    
    override init() {
        super.init()
        title = "buyNowPayLater.title".localized()
        setUpScrollContainerViewConstraints()
        setUpAmountFieldConstraints()
        setUpAccountTypeFieldConstraints()
        setUpProductsFieldConstraints()
        setUpBillingFieldConstraints()
        setUpShippingFieldConstraints()
        setUpContainerPhoneNumberFieldConstraints()
        setUpCustomerFieldConstraints()
        setUpBnplButtonConstraints()
        
        setUpSeparatorBottomLineConstraints(containerView, belowView: bnplButton)
        setUpCodeResponseViewConstraints(containerView)
        setUpDataExampleCode()
        
        setUpLoadingViewConstraints()
    }
    
    private func setUpDataExampleCode() {
        codeResponseView.locationLabel = "Modules/BuyNowPayLater/"
        codeResponseView.fileLabel = "BuyNowPayLaterViewModel.swift"
        codeResponseView.titleResponseDataView = "BuyNowPayLaterInfo"
        codeResponseView.exampleCodeImage = #imageLiteral(resourceName: "bnpl_code")
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
    
    
    private func setUpAccountTypeFieldConstraints() {
        containerView.addSubview(accountTypeFieldView)
        NSLayoutConstraint.activating([
            accountTypeFieldView.relativeTo(amountFieldView, positioned: .belowWidth(spacing: DimensKeys.marginMedium))
        ])
    }
    
    private func setUpProductsFieldConstraints() {
        containerView.addSubview(productsFieldView)
        NSLayoutConstraint.activating([
            productsFieldView.relativeTo(accountTypeFieldView, positioned: .belowWidth(spacing: DimensKeys.marginMedium))
        ])
    }
    
    private func setUpBillingFieldConstraints() {
        containerView.addSubview(billingAddressFieldView)
        NSLayoutConstraint.activating([
            billingAddressFieldView.relativeTo(productsFieldView, positioned: .belowWidth(spacing: DimensKeys.marginMedium))
        ])
    }
    
    private func setUpShippingFieldConstraints() {
        containerView.addSubview(shippingAddressFieldView)
        NSLayoutConstraint.activating([
            shippingAddressFieldView.relativeTo(billingAddressFieldView, positioned: .belowWidth(spacing: DimensKeys.marginMedium))
        ])
    }
    
    private func setUpContainerPhoneNumberFieldConstraints() {
        containerView.addSubview(containerPhoneNumber)
        containerPhoneNumber.addSubview(countryCodeFieldView)
        containerPhoneNumber.addSubview(phoneNumberFieldView)
        containerPhoneNumber.addSubview(phoneTypeFieldView)
        NSLayoutConstraint.activating([
            containerPhoneNumber.relativeTo(shippingAddressFieldView, positioned: .belowWidth(spacing: DimensKeys.marginMedium)),
            countryCodeFieldView.relativeTo(containerPhoneNumber, positioned: .left() + .top() + .bottom() + .constantWidth(70)),
            phoneNumberFieldView.relativeTo(countryCodeFieldView, positioned: .toRight(spacing: DimensKeys.marginSmall)),
            phoneTypeFieldView.relativeTo(phoneNumberFieldView, positioned: .toRight(spacing: DimensKeys.marginSmall) + .constantWidth(120)),
            phoneTypeFieldView.relativeTo(containerPhoneNumber, positioned: .right()),
            
        ])
    }
    
    private func setUpCustomerFieldConstraints() {
        containerView.addSubview(customerFieldView)
        NSLayoutConstraint.activating([
            customerFieldView.relativeTo(containerPhoneNumber, positioned: .belowWidth(spacing: DimensKeys.marginMedium))
        ])
    }
    
    private func setUpBnplButtonConstraints() {
        containerView.addSubview(bnplButton)
        NSLayoutConstraint.activating([
            bnplButton.relativeTo(customerFieldView, positioned: .belowWidth(spacing: DimensKeys.marginMedium, margin: DimensKeys.marginSide)),
            bnplButton.constrainedBy(.constantHeight(DimensKeys.buttonSize))
        ])
    }
    
    func defaultValues() {
        amountFieldView.text = defaultAmount
        accountTypeFieldView.text = BNPLType.AFFIRM.mapped(for: .gpApi)
        phoneTypeFieldView.text = PhoneNumberType.Home.mapped(for: .gpApi)
        countryCodeFieldView.text = "1"
        phoneNumberFieldView.text = "7708298000"
    }
    
    func setProductsLabel(value: String) {
        productsFieldView.text = value
    }
    
    func setBillingLabel(value: String) {
        billingAddressFieldView.text = value
    }
    
    func setShippingLabel(value: String) {
        shippingAddressFieldView.text = value
    }
    
    func setCustomerLabel(value: String) {
        customerFieldView.text = value
    }
    
    @objc func bnplButtonPressed() {
        delegate?.onBnplPressed()
    }
    
    func enableButton(_ enable: Bool) {
        bnplButton.isEnabled = enable
        bnplButton.alpha = enable ? DimensKeys.enabledButton : DimensKeys.disabledButton
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

extension BuyNowPayLaterView: GpTextFieldDelegate {
    
    func textChanged(value: String, type: GpFieldsEnum) {
        delegate?.fieldDataChanged(value: value, type: type)
    }
}
