import UIKit

protocol PaypalViewViewDelegate: AnyObject {
    func onChargeButtonAction()
    func onAuthorizeButtonAction()
    func fieldDataChanged(value: String, type: GpFieldsEnum)
}

class PaypalView: GpBaseView {
    
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
    
    weak var delegate: PaypalViewViewDelegate?
    
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
    
    private lazy var chargeButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.applyWithImage(style: .redesignStyle, title: "ach.charge".localized())
        button.addTarget(self, action: #selector(chargeButtonPressed), for: .touchUpInside)
        button.isEnabled = false
        button.alpha = DimensKeys.disabledButton
        return button
    }()
    
    private lazy var authorizeButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.applyWithImage(style: .redesignStyle, title: "ach.authorize".localized())
        button.addTarget(self, action: #selector(chargeButtonPressed), for: .touchUpInside)
        button.isEnabled = false
        button.alpha = DimensKeys.disabledButton
        return button
    }()
    
    override init() {
        super.init()
        title = "paypal.title".localized()
        setUpScrollContainerViewConstraints()
        setUpAmountFieldConstraints()
        setUpChargeButtonConstraints()
        setUpAuthorizeButtonConstraints()
        
        setUpSeparatorBottomLineConstraints(containerView, belowView: authorizeButton)
        setUpCodeResponseViewConstraints(containerView)
        setUpDataExampleCode()
        
        setUpLoadingViewConstraints()
    }
    
    private func setUpDataExampleCode() {
        codeResponseView.locationLabel = "Modules/Paypal/"
        codeResponseView.fileLabel = "PaypalViewModel.swift"
        codeResponseView.titleResponseDataView = "PayPalInfo"
        codeResponseView.exampleCodeImage = #imageLiteral(resourceName: "paypal_code")
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
    
    private func setUpChargeButtonConstraints() {
        containerView.addSubview(chargeButton)
        NSLayoutConstraint.activating([
            chargeButton.relativeTo(amountFieldView, positioned: .belowWidth(spacing: DimensKeys.marginMedium, margin: DimensKeys.marginSide)),
            chargeButton.constrainedBy(.constantHeight(DimensKeys.buttonSize))
        ])
    }
    
    private func setUpAuthorizeButtonConstraints() {
        containerView.addSubview(authorizeButton)
        NSLayoutConstraint.activating([
            authorizeButton.relativeTo(chargeButton, positioned: .belowWidth(spacing: DimensKeys.marginMedium)),
            authorizeButton.constrainedBy(.constantHeight(DimensKeys.buttonSize))
        ])
    }
    
    func defaultValues() {
        amountFieldView.text = defaultAmount
    }
    
    @objc func chargeButtonPressed() {
        delegate?.onChargeButtonAction()
    }
    
    @objc func authorizeButtonPressed() {
        delegate?.onAuthorizeButtonAction()
    }
    
    func enableButtons(_ enable: Bool) {
        chargeButton.isEnabled = enable
        chargeButton.alpha = enable ? DimensKeys.enabledButton : DimensKeys.disabledButton
        authorizeButton.isEnabled = enable
        authorizeButton.alpha = enable ? DimensKeys.enabledButton : DimensKeys.disabledButton
    }
}

extension PaypalView: GpTextFieldDelegate {
    
    func textChanged(value: String, type: GpFieldsEnum) {
        delegate?.fieldDataChanged(value: value, type: type)
    }
}

