import UIKit
import GlobalPayments_iOS_SDK

protocol PaymentOperationFormViewDelegate: AnyObject {
    func onSubmitPressed()
    func fieldDataChanged(value: String, type: GpFieldsEnum)
}

class PaymentOperationFormView: GpBaseView {
    
    private let defaultAmount = "10.00"
    
    private var paymentCardFieldConstraint: NSLayoutConstraint?
    private var fingerprintFieldConstraint: NSLayoutConstraint?
    private var paymentIdFieldConstraint: NSLayoutConstraint?
    private var currencyConstraints: [NSLayoutConstraint] = []
    private var cardHolderNameFieldConstraint: NSLayoutConstraint?
    private var constraintsToHandle: [NSLayoutConstraint] = []
    private var viewsToHandle: [UIView] = []
    
    private struct DimensKeys {
        static let marginTop: CGFloat = 20
        static let marginSide: CGFloat = 20
        static let marginSmall: CGFloat = 5
        static let marginMedium: CGFloat = 15
        static let disabledButton: CGFloat = 0.3
        static let enabledButton: CGFloat = 1.0
        static let buttonSize: CGFloat = 48.0
    }
    
    weak var delegate: PaymentOperationFormViewDelegate?
    
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
    
    private lazy var paymentOperationFieldView: GpTextFieldView = {
        let field = GpTextFieldView()
        field.title = "payment.operation.form.payment.operation".localized()
        field.setDropDown(PaymentMethodOperationType.allCases.map { $0.rawValue.uppercased() }, onSelectItem: onChangePaymentMethod, defaultValue: 0)
        field.delegate = self
        field.tagField = .paymentOperation
        field.translatesAutoresizingMaskIntoConstraints = false
        return field
    }()
    
    private lazy var paymentIdFieldView: GpTextFieldView = {
        let field = GpTextFieldView()
        field.titleMandatory = "payment.methods.report.id.payment.method".localized()
        field.tagField = .paymentId
        field.delegate = self
        field.translatesAutoresizingMaskIntoConstraints = false
        return field
    }()
    
    private lazy var paymentCardFieldView: GpTextFieldView = {
        let field = GpTextFieldView()
        field.title = "payment.operation.form.payment.card".localized()
        field.setDropDown(PaymentCardModel.models.map { $0.name }, onSelectItem: onChangePaymentCard, defaultValue: 0)
        field.delegate = self
        field.tagField = .paymentOperation
        field.translatesAutoresizingMaskIntoConstraints = false
        return field
    }()
    
    private lazy var tokenUsageModeFieldView: GpTextFieldView = {
        let field = GpTextFieldView()
        field.title = "payment.operation.form.payment.token.usage.mode".localized()
        field.setDropDown(PaymentMethodUsageMode.allCases.map{ $0.rawValue}, defaultValue: 0)
        field.delegate = self
        field.tagField = .tokenUsage
        field.translatesAutoresizingMaskIntoConstraints = false
        return field
    }()
    
    private lazy var cardHolderNameFieldView: GpTextFieldView = {
        let field = GpTextFieldView()
        field.titleMandatory = "check.availability.form.card.holder.name".localized()
        field.tagField = .cardHolderName
        field.delegate = self
        field.translatesAutoresizingMaskIntoConstraints = false
        return field
    }()
    
    private lazy var fingerprintContainer: UIView = {
        let container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false
        container.backgroundColor = #colorLiteral(red: 0.9490196078, green: 0.9490196078, blue: 0.968627451, alpha: 1)
        container.cornerRadius = 5.0
        return container
    }()
    
    private lazy var fingerprintLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "expand.stored.payment.methods.enable.fingerprint".localized()
        return label
    }()
    
    private lazy var fingerprintSwitch: UISwitch = {
        let switchButton = UISwitch()
        switchButton.addTarget(self, action: #selector(onSwitchValueChanged(_:)), for: .valueChanged)
        switchButton.translatesAutoresizingMaskIntoConstraints = false
        return switchButton
    }()
    
    private lazy var fingerprintFieldView: GpTextFieldView = {
        let field = GpTextFieldView()
        field.title = "expand.stored.payment.methods.fingerprint.mode".localized()
        field.setDropDown(FingerprintUsageModeEnum.allCases.map{ $0.rawValue})
        field.delegate = self
        field.tagField = .fingerprintType
        field.translatesAutoresizingMaskIntoConstraints = false
        return field
    }()
    
    private lazy var cardNumberFieldView: GpTextFieldView = {
        let field = GpTextFieldView()
        field.titleMandatory = "transactoin.operations.form.card.number".localized()
        field.tagField = .cardNumber
        field.delegate = self
        field.translatesAutoresizingMaskIntoConstraints = false
        return field
    }()
    
    private lazy var cardExpCardCvvFieldsView: GpDoubleFieldView = {
        let fields = GpDoubleFieldView()
        fields.translatesAutoresizingMaskIntoConstraints = false
        fields.firstMandatory = "unified.payments.card.expiration.date".localized()
        fields.secondMandatory = "verifications.form.cvn".localized()
        
        fields.setFirstTagField(.cardExpiryDate, delegate: self)
        fields.setSecondTagField(.cardCvv, delegate: self)
        
        fields.firstInputPickerView = datePicker()
        return fields
    }()
    
    private lazy var currencyFieldView: GpTextFieldView = {
        let field = GpTextFieldView()
        field.title = "deposits.currency".localized()
        field.setDropDown(Currency.allCases.map{ $0.rawValue}, defaultValue: 0)
        field.delegate = self
        field.tagField = .currencyType
        field.translatesAutoresizingMaskIntoConstraints = false
        return field
    }()
    
    private lazy var storedPaymentButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.applyWithImage(style: .redesignStyle, title: "payment.operation.form.submit".localized())
        button.addTarget(self, action: #selector(submitButtonPressed), for: .touchUpInside)
        return button
    }()
    
    override init() {
        super.init()
        title = "expand.stored.payment.methods.title".localized()
        setUpScrollContainerViewConstraints()
        setUpPaymentOperationFieldConstraints()
        setUpPaymentIdFieldConstraints()
        setUpPaymentCardFieldConstraints()
        setUpTokenUsageModeFieldConstraints()
        setUpCardHolderNameFieldConstraints()
        setUpFingerprintContainerContraints()
        setUpFingerprintFieldConstraints()
        setUpCardNumberFieldConstraints()
        setUpCardExpCardCvvFieldsConstraints()
        setUpCurrencyFieldConstraints()
        setUpStoredPaymentButtonConstraints()
        
        setUpSeparatorBottomLineConstraints(containerView, belowView: storedPaymentButton)
        setUpCodeResponseViewConstraints(containerView)
        setUpDataExampleCode()
        
        setUpLoadingViewConstraints()
        
        constraintsToHandle.forEach { $0.isActive = true }
    }
    
    private func setUpDataExampleCode() {
        codeResponseView.locationLabel = "Modules/StoredPaymentsMethods/"
        codeResponseView.fileLabel = "PaymentOperationFormViewModel.swift"
        codeResponseView.titleResponseDataView = "StoredPaymentsInfo"
        codeResponseView.exampleCodeImage = #imageLiteral(resourceName: "stored_payments_code")
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
    
    private func setUpPaymentOperationFieldConstraints() {
        containerView.addSubview(paymentOperationFieldView)
        NSLayoutConstraint.activating([
            paymentOperationFieldView.relativeTo(containerView, positioned: .top() + .width())
        ])
    }
    
    private func setUpPaymentIdFieldConstraints() {
        containerView.addSubview(paymentIdFieldView)
        paymentIdFieldView.isHidden = true
        
        paymentIdFieldConstraint = paymentIdFieldView.heightAnchor.constraint(equalToConstant: 0)
        paymentIdFieldConstraint?.isActive = true
        
        NSLayoutConstraint.activating([
            paymentIdFieldView.relativeTo(paymentOperationFieldView, positioned: .belowWidth(spacing: DimensKeys.marginMedium))
        ])
    }
    
    private func setUpPaymentCardFieldConstraints() {
        containerView.addSubview(paymentCardFieldView)
        
        constraintsToHandle.append(paymentCardFieldView.heightAnchor.constraint(equalToConstant: 80))
        viewsToHandle.append(paymentCardFieldView)
        
        NSLayoutConstraint.activating([
            paymentCardFieldView.relativeTo(paymentIdFieldView, positioned: .belowWidth(spacing: DimensKeys.marginMedium))
        ])
    }
    
    private func setUpTokenUsageModeFieldConstraints() {
        containerView.addSubview(tokenUsageModeFieldView)
        
        constraintsToHandle.append(tokenUsageModeFieldView.heightAnchor.constraint(equalToConstant: 80))
        viewsToHandle.append(tokenUsageModeFieldView)
        
        NSLayoutConstraint.activating([
            tokenUsageModeFieldView.relativeTo(paymentCardFieldView, positioned: .belowWidth(spacing: DimensKeys.marginMedium))
        ])
    }
    
    private func setUpCardHolderNameFieldConstraints() {
        containerView.addSubview(cardHolderNameFieldView)
        cardHolderNameFieldView.isHidden = true
        
        cardHolderNameFieldConstraint = cardHolderNameFieldView.heightAnchor.constraint(equalToConstant: 0)
        cardHolderNameFieldConstraint?.isActive = true
        
        NSLayoutConstraint.activating([
            cardHolderNameFieldView.relativeTo(tokenUsageModeFieldView, positioned: .belowWidth(spacing: DimensKeys.marginMedium))
        ])
    }
    
    private func setUpFingerprintContainerContraints() {
        containerView.addSubview(fingerprintContainer)
        fingerprintContainer.addSubview(fingerprintLabel)
        fingerprintContainer.addSubview(fingerprintSwitch)
        
        constraintsToHandle.append(fingerprintContainer.heightAnchor.constraint(equalToConstant: 80))
        viewsToHandle.append(fingerprintContainer)
        
        NSLayoutConstraint.activating([
            fingerprintContainer.relativeTo(cardHolderNameFieldView, positioned: .belowWidth(spacing: DimensKeys.marginMedium)),
            fingerprintLabel.relativeTo(fingerprintContainer, positioned: .top(margin: DimensKeys.marginTop) + .bottom(margin: DimensKeys.marginTop) + .left(margin: DimensKeys.marginMedium)),
            fingerprintSwitch.relativeTo(fingerprintContainer, positioned: .right(margin: DimensKeys.marginMedium) + .centerY() + .constantHeight(30) )
        ])
    }
    
    private func setUpFingerprintFieldConstraints() {
        containerView.addSubview(fingerprintFieldView)
        fingerprintFieldView.isHidden = true
        
        fingerprintFieldConstraint = fingerprintFieldView.heightAnchor.constraint(equalToConstant: 0)
        fingerprintFieldConstraint?.isActive = true
        
        NSLayoutConstraint.activating([
            fingerprintFieldView.relativeTo(fingerprintContainer, positioned: .belowWidth(spacing: DimensKeys.marginMedium))
        ])
    }
    
    private func setUpCardNumberFieldConstraints() {
        containerView.addSubview(cardNumberFieldView)
        
        constraintsToHandle.append(cardNumberFieldView.heightAnchor.constraint(equalToConstant: 80))
        viewsToHandle.append(cardNumberFieldView)
        
        NSLayoutConstraint.activating([
            cardNumberFieldView.relativeTo(fingerprintFieldView, positioned: .belowWidth(spacing: DimensKeys.marginMedium))
        ])
    }
    
    private func setUpCardExpCardCvvFieldsConstraints() {
        containerView.addSubview(cardExpCardCvvFieldsView)
        
        constraintsToHandle.append(cardExpCardCvvFieldsView.heightAnchor.constraint(equalToConstant: 80))
        viewsToHandle.append(cardExpCardCvvFieldsView)
        
        NSLayoutConstraint.activating([
            cardExpCardCvvFieldsView.relativeTo(cardNumberFieldView, positioned: .belowWidth(spacing: DimensKeys.marginMedium))
        ])
    }
    
    private func setUpCurrencyFieldConstraints() {
        containerView.addSubview(currencyFieldView)
        NSLayoutConstraint.activating([
            currencyFieldView.relativeTo(cardExpCardCvvFieldsView, positioned: .belowWidth(spacing: DimensKeys.marginMedium))
        ])
    }
    
    private func setUpStoredPaymentButtonConstraints() {
        containerView.addSubview(storedPaymentButton)
        NSLayoutConstraint.activating([
            storedPaymentButton.relativeTo(currencyFieldView, positioned: .belowWidth(spacing: DimensKeys.marginMedium)),
            storedPaymentButton.constrainedBy(.constantHeight(DimensKeys.buttonSize))
        ])
    }
    
    func defaultValues() {
        onChangePaymentCard(name: PaymentCardModel.models.first?.name ?? "")
    }
    
    @objc func submitButtonPressed() {
        delegate?.onSubmitPressed()
    }
    
    func enableButton(_ enable: Bool) {
        storedPaymentButton.isEnabled = enable
        storedPaymentButton.alpha = enable ? DimensKeys.enabledButton : DimensKeys.disabledButton
    }
    
    func toBottomView() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.moveToBottomView()
        }
    }
    
    @objc private func onSwitchValueChanged(_ switchButton: UISwitch) {
        fingerprintFieldConstraint?.constant = switchButton.isOn ? 80 : 0
        fingerprintFieldView.isHidden = !switchButton.isOn
        fingerprintFieldView.text = ""
    }
    
    private func moveToBottomView() {
        let bottomOffset = CGPoint(x: 0, y: scrollContainerView.contentSize.height - scrollContainerView.bounds.height + scrollContainerView.contentInset.bottom)
        scrollContainerView.setContentOffset(bottomOffset, animated: true)
    }
    
    private func datePicker() -> UIDatePicker{
        let datePickerView = UIDatePicker()
        datePickerView.datePickerMode = .date
        if #available(iOS 14, *) {
            datePickerView.preferredDatePickerStyle = .inline
        }
        datePickerView.addTarget(self, action: #selector(handleChange(sender:)), for: .valueChanged)
        return datePickerView
    }
    
    @objc func handleChange(sender: UIDatePicker){
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/yyyy"
        cardExpCardCvvFieldsView.firstText = dateFormatter.string(from: sender.date)
    }
    
    private func onChangePaymentCard(name: String) {
        guard let paymentCard = PaymentCardModel.models.filter({ $0.name == name }).first else {
            return
        }
        cardNumberFieldView.text = paymentCard.number
        let expiryDate = "\(paymentCard.month)/\(paymentCard.year)"
        cardExpCardCvvFieldsView.firstText = expiryDate
        cardExpCardCvvFieldsView.secondText = paymentCard.cvv
    }
    
    private func onChangePaymentMethod(_ value: String) {
        let type = PaymentMethodOperationType(value: value) ?? .tokenize
        
        constraintsToHandle.forEach {
            $0.constant = 80
            $0.isActive = true
        }
        
        if (window != nil) {
            if !currencyConstraints.isEmpty {
                viewsToHandle.forEach { containerView.addSubview($0)}
                resetConstraints()
                layoutIfNeeded()
            }
        }
        
        currencyConstraints = []
        
        switch type {
        case .edit:
            paymentIdFieldConstraint?.constant = 80
            cardHolderNameFieldConstraint?.constant = 80
            paymentIdFieldView.isHidden = false
            cardHolderNameFieldView.isHidden = false
        case .tokenize:
            paymentIdFieldConstraint?.constant = 0
            cardHolderNameFieldConstraint?.constant = 0
            paymentIdFieldView.isHidden = true
            cardHolderNameFieldView.isHidden = true
        case .delete:
            paymentIdFieldConstraint?.constant = 80
            cardHolderNameFieldConstraint?.constant = 0
            paymentIdFieldView.isHidden = false
            cardHolderNameFieldView.isHidden = true
            
            viewsToHandle.forEach { $0.removeFromSuperview()}
            
            currencyConstraints = currencyFieldView.relativeTo(paymentIdFieldView, positioned: .belowWidth(spacing: DimensKeys.marginMedium))
            NSLayoutConstraint.activating([currencyConstraints])
            
            layoutIfNeeded()
        }
    }
    
    private func resetConstraints() {
        currencyFieldView.removeFromSuperview()
        containerView.addSubview(currencyFieldView)
        NSLayoutConstraint.activating([
            paymentIdFieldView.relativeTo(paymentOperationFieldView, positioned: .belowWidth(spacing: DimensKeys.marginMedium)),
            paymentCardFieldView.relativeTo(paymentIdFieldView, positioned: .belowWidth(spacing: DimensKeys.marginMedium)),
            tokenUsageModeFieldView.relativeTo(paymentCardFieldView, positioned: .belowWidth(spacing: DimensKeys.marginMedium)),
            cardHolderNameFieldView.relativeTo(tokenUsageModeFieldView, positioned: .belowWidth(spacing: DimensKeys.marginMedium)),
            fingerprintContainer.relativeTo(cardHolderNameFieldView, positioned: .belowWidth(spacing: DimensKeys.marginMedium)),
            fingerprintFieldView.relativeTo(fingerprintContainer, positioned: .belowWidth(spacing: DimensKeys.marginMedium)),
            cardNumberFieldView.relativeTo(fingerprintFieldView, positioned: .belowWidth(spacing: DimensKeys.marginMedium)),
            cardExpCardCvvFieldsView.relativeTo(cardNumberFieldView, positioned: .belowWidth(spacing: DimensKeys.marginMedium)),
            currencyFieldView.relativeTo(cardExpCardCvvFieldsView, positioned: .belowWidth(spacing: DimensKeys.marginMedium)),
            storedPaymentButton.relativeTo(currencyFieldView, positioned: .belowWidth(spacing: DimensKeys.marginMedium)),
        ])
    }
}

extension PaymentOperationFormView: GpTextFieldDelegate {
    
    func textChanged(value: String, type: GpFieldsEnum) {
        delegate?.fieldDataChanged(value: value, type: type)
    }
}


