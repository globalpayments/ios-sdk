import UIKit

protocol UnifiedPaymentsViewDelegate: AnyObject {
    func fieldDataChanged(value: String, type: GpFieldsEnum)
    func makeRecurringEnabled(_ value: Bool)
    func onChargeAction()
}

class UnifiedPaymentsView: GpBaseView {
    
    private let defaultAmount = "0.0"
    
    private struct DimensKeys {
        static let margin: CGFloat = 10
        static let marginSmall: CGFloat = 5
        static let marginMedium: CGFloat = 15
        static let marginBig: CGFloat = 20
        static let disabledButton: CGFloat = 0.3
        static let enabledButton: CGFloat = 1.0
    }
    
    weak var delegate: UnifiedPaymentsViewDelegate?
    
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
        field.text = defaultAmount
        field.inputMode = .decimalPad
        field.currency = "$"
        field.translatesAutoresizingMaskIntoConstraints = false
        return field
    }()
    
    private lazy var makeRecurringSwitch: GpLabelSwitchView = {
        let switchButton = GpLabelSwitchView()
        switchButton.addAction(self, selector: #selector(onSwitchValueChanged(_:)))
        switchButton.title = "Make payment recurring"
        switchButton.translatesAutoresizingMaskIntoConstraints = false
        return switchButton
    }()
    
    private lazy var paymentCardsFieldView: GpTextFieldView = {
        let field = GpTextFieldView()
        field.title = "payment.operation.form.payment.card".localized()
        field.setDropDown(PaymentCardModel.modelsWith3ds.map { $0.name }, onSelectItem: onChangePaymentCard)
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
    
    private lazy var cardHolderNameFieldView: GpTextFieldView = {
        let field = GpTextFieldView()
        field.titleMandatory = "check.availability.form.card.holder.name".localized()
        field.tagField = .cardHolderName
        field.delegate = self
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
    
    override init() {
        super.init()
        title = "payment.process.unified.payments.title".localized()
        descriptionValue = "payment.process.unified.payments.description".localized()
        descriptionTextAlignment = .center
        
        setUpScrollContainerViewConstraints()
        setUpAmountFieldConstraints()
        setUpRecurringPaymentContainerContraints()
        setUpPaymentCardsFieldConstraints()
        setUpCardNumberFieldConstraints()
        setUpCardExpCardCvvFieldsConstraints()
        setUpCardHolderNameFieldConstraints()
        setUpChargeButtonConstraints()
        
        setUpSeparatorBottomLineConstraints(containerView, belowView: chargeButton)
        setUpCodeResponseViewConstraints(containerView)
        setUpDataExampleCode()
        setUpLoadingViewConstraints()
    }
    
    private func setUpDataExampleCode() {
        codeResponseView.locationLabel = "Modules/UnifiedPayments/"
        codeResponseView.fileLabel = "UnifiedPaymentsViewModel.swift"
        codeResponseView.titleResponseDataView = "UnifiedPaymentsInfo"
        codeResponseView.exampleCodeImage = #imageLiteral(resourceName: "unified_payments_code")
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
    
    private func setUpRecurringPaymentContainerContraints() {
        containerView.addSubview(makeRecurringSwitch)
        NSLayoutConstraint.activating([
            makeRecurringSwitch.relativeTo(amountFieldView, positioned: .belowWidth(spacing: DimensKeys.marginMedium))
        ])
    }
    
    private func setUpPaymentCardsFieldConstraints() {
        containerView.addSubview(paymentCardsFieldView)
        NSLayoutConstraint.activating([
            paymentCardsFieldView.relativeTo(makeRecurringSwitch, positioned: .belowWidth(spacing: DimensKeys.marginMedium))
        ])
    }
    
    private func setUpCardNumberFieldConstraints() {
        containerView.addSubview(cardNumberFieldView)
        NSLayoutConstraint.activating([
            cardNumberFieldView.relativeTo(paymentCardsFieldView, positioned: .belowWidth(spacing: DimensKeys.marginMedium))
        ])
    }
    
    private func setUpCardExpCardCvvFieldsConstraints() {
        containerView.addSubview(cardExpCardCvvFieldsView)
        NSLayoutConstraint.activating([
            cardExpCardCvvFieldsView.relativeTo(cardNumberFieldView, positioned: .belowWidth(spacing: DimensKeys.marginMedium))
        ])
    }
    
    private func setUpCardHolderNameFieldConstraints() {
        containerView.addSubview(cardHolderNameFieldView)
        NSLayoutConstraint.activating([
            cardHolderNameFieldView.relativeTo(cardExpCardCvvFieldsView, positioned: .belowWidth(spacing: DimensKeys.marginMedium))
        ])
    }
    
    private func setUpChargeButtonConstraints() {
        containerView.addSubview(chargeButton)
        NSLayoutConstraint.activating([
            chargeButton.relativeTo(containerView, positioned: .width(DimensKeys.marginBig)),
            chargeButton.constrainedBy(.constantHeight(48)),
            chargeButton.relativeTo(cardHolderNameFieldView, positioned: .below(spacing: DimensKeys.marginMedium))
        ])
    }
    
    @objc func chargeButtonPressed() {
        delegate?.onChargeAction()
    }
    
    func enableChargeButton(_ enable: Bool) {
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
    
    private func onChangePaymentCard(name: String) {
        guard let paymentCard = PaymentCardModel.modelsWith3ds.filter({ $0.name == name }).first else {
            return
        }
        cardNumberFieldView.text = paymentCard.number
        let expiryDate = "\(paymentCard.month)/\(paymentCard.year)"
        cardExpCardCvvFieldsView.firstText = expiryDate
        cardExpCardCvvFieldsView.secondText = paymentCard.cvv
    }
    
    @objc private func onSwitchValueChanged(_ switchButton: UISwitch) {
        delegate?.makeRecurringEnabled(switchButton.isOn)
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
}

extension UnifiedPaymentsView: GpTextFieldDelegate {
    
    func textChanged(value: String, type: GpFieldsEnum) {
        delegate?.fieldDataChanged(value: value, type: type)
    }
}
