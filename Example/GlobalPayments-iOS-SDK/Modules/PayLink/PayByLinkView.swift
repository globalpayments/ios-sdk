import UIKit
import GlobalPayments_iOS_SDK

protocol PayByLinkViewDelegate: AnyObject {
    func onPayBylinkButtonAction()
    func fieldDataChanged(value: String, type: GpFieldsEnum)
}

class PayByLinkView: GpBaseView {
    
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
    
    weak var delegate: PayByLinkViewDelegate?
    
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
    
    private lazy var descriptionFieldView: GpTextFieldView = {
        let field = GpTextFieldView()
        field.title = "payment.process.description.tittle".localized()
        field.tagField = .description
        field.delegate = self
        field.translatesAutoresizingMaskIntoConstraints = false
        return field
    }()
    
    private lazy var usageModeFieldsView: GpDoubleFieldView = {
        let fields = GpDoubleFieldView()
        fields.translatesAutoresizingMaskIntoConstraints = false
        fields.firstTitle = "payment.process.usage.mode.tittle".localized()
        fields.secondTitle = "payment.process.usage.limit.tittle".localized()
        fields.setFirstTagField(.usageMode, delegate: self)
        fields.setSecondTagField(.usageLimit, delegate: self)
        fields.enableInputSecondField = false
        fields.delegate = self
        return fields
    }()
    
    private lazy var expirationDateFieldView: GpTextFieldView = {
        let field = GpTextFieldView()
        field.titleMandatory = "payment.process.expiration.date.tittle".localized()
        field.tagField = .expirationDate
        field.setDateDropDown(format: "yyyy-MM-dd")
        field.delegate = self
        field.translatesAutoresizingMaskIntoConstraints = false
        return field
    }()
    
    private lazy var payByLinkButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.applyWithImage(style: .redesignStyle, title: "payment.process.payByLink.button.tittle".localized())
        button.addTarget(self, action: #selector(payByLinkButtonPressed), for: .touchUpInside)
        button.isEnabled = false
        button.alpha = DimensKeys.disabledButton
        return button
    }()
    
    override init() {
        super.init()
        title = "payByLink.title".localized()
        setUpScrollContainerViewConstraints()
        setUpAmountFieldConstraints()
        setUpDescriptionFieldConstraints()
        setUpExpirationDateFieldConstraints()
        setUpUsageModeFieldConstraints()
        setUpPayByLinkButtonConstraints()
        
        setUpSeparatorBottomLineConstraints(containerView, belowView: payByLinkButton)
        setUpCodeResponseViewConstraints(containerView)
        setUpDataExampleCode()
        
        setUpLoadingViewConstraints()
    }
    
    private func setUpDataExampleCode() {
        codeResponseView.locationLabel = "Modules/PayBylink/"
        codeResponseView.fileLabel = "PayByLinkViewModel.swift"
        codeResponseView.titleResponseDataView = "PayByLinkInfo"
//        codeResponseView.exampleCodeImage = #imageLiteral(resourceName: "pay_by_link_code")
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
    
    private func setUpDescriptionFieldConstraints() {
        containerView.addSubview(descriptionFieldView)
        NSLayoutConstraint.activating([
            descriptionFieldView.relativeTo(amountFieldView, positioned: .belowWidth(spacing: DimensKeys.marginMedium))
        ])
    }
    
    private func setUpExpirationDateFieldConstraints() {
        containerView.addSubview(expirationDateFieldView)
        NSLayoutConstraint.activating([
            expirationDateFieldView.relativeTo(descriptionFieldView, positioned: .belowWidth(spacing: DimensKeys.marginMedium))
        ])
    }
    
    private func setUpUsageModeFieldConstraints() {
        containerView.addSubview(usageModeFieldsView)
        NSLayoutConstraint.activating([
            usageModeFieldsView.relativeTo(expirationDateFieldView, positioned: .belowWidth(spacing: DimensKeys.marginMedium))
        ])
    }
    
    private func setUpPayByLinkButtonConstraints() {
        containerView.addSubview(payByLinkButton)
        NSLayoutConstraint.activating([
            payByLinkButton.relativeTo(usageModeFieldsView, positioned: .belowWidth(spacing: DimensKeys.marginMedium, margin: DimensKeys.marginSide)),
            payByLinkButton.constrainedBy(.constantHeight(DimensKeys.buttonSize))
        ])
    }
    
    func defaultValues() {
        amountFieldView.text = defaultAmount
        descriptionFieldView.text = "Where's the money Lebowsky"
        
        let usageModes = PaymentMethodUsageMode.allCases.map { "\($0)".uppercased() }
        usageModeFieldsView.setDropDownBoth(usageModes, defaultFirstValue: 0)
    }
    
    @objc func payByLinkButtonPressed() {
        delegate?.onPayBylinkButtonAction()
    }
    
    func enableButton(_ enable: Bool) {
        payByLinkButton.isEnabled = enable
        payByLinkButton.alpha = enable ? DimensKeys.enabledButton : DimensKeys.disabledButton
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

extension PayByLinkView: DoubleFieldViewDelegate {
    
    func onFirstFieldItemSelected(_ value: String) {
        guard let usageMode = PaymentMethodUsageMode(value: value) else {
            return
        }
        
        switch usageMode {
        case .single:
            usageModeFieldsView.secondText = "1"
        case .multiple:
            usageModeFieldsView.secondText = "2"
        }
    }
}

extension PayByLinkView: GpTextFieldDelegate {
    
    func textChanged(value: String, type: GpFieldsEnum) {
        delegate?.fieldDataChanged(value: value, type: type)
    }
}

