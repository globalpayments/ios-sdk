import UIKit
import GlobalPayments_iOS_SDK

protocol MerchantEditViewDelegate: AnyObject {
    func onEditAccount()
    func onBillingPressed()
    func fieldDataChanged(value: String, type: GpFieldsEnum)
}

class MerchantEditView: GpBaseView {
    
    private let defaultBatch = "BAT_915858-767"
    
    private struct DimensKeys {
        static let marginTop: CGFloat = 20
        static let marginSide: CGFloat = 20
        static let marginSmall: CGFloat = 5
        static let marginMedium: CGFloat = 15
        static let disabledButton: CGFloat = 0.3
        static let enabledButton: CGFloat = 1.0
        static let buttonSize: CGFloat = 48.0
    }
    
    weak var delegate: MerchantEditViewDelegate?
    
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
    
    private lazy var paymentCardFieldView: GpTextFieldView = {
        let field = GpTextFieldView()
        field.title = "payment.operation.form.payment.card".localized()
        field.setDropDown(PaymentCardModel.models.map { $0.name }, onSelectItem: onChangePaymentCard, defaultValue: 0)
        field.delegate = self
        field.tagField = .paymentOperation
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
        
        fields.firstInputPickerView = datePicker(.cardExpiryDate)
        return fields
    }()
    
    private lazy var cardHolderNameFieldView: GpTextFieldView = {
        let field = GpTextFieldView()
        field.title = "check.availability.form.card.holder.name".localized()
        field.tagField = .cardHolderName
        field.delegate = self
        field.translatesAutoresizingMaskIntoConstraints = false
        return field
    }()
    
    private lazy var fromToTimeCreatedFieldsView: GpDoubleFieldView = {
        let fields = GpDoubleFieldView()
        fields.translatesAutoresizingMaskIntoConstraints = false
        fields.firstTitle = "deposits.list.form.from.time.created".localized()
        fields.secondTitle = "deposits.list.form.to.time.created".localized()
        
        fields.setFirstTagField(.fromTimeCreated, delegate: self)
        fields.setSecondTagField(.toTimeCreated, delegate: self)
        
        fields.firstInputPickerView = datePicker(.fromTimeCreated)
        fields.secondInputPickerView = datePicker(.toTimeCreated)
        return fields
    }()
    
    private lazy var billingAddressFieldView: GpTextFieldView = {
        let field = GpTextFieldView()
        field.title = "bnpl.billing.address.title".localized()
        field.tagField = .billing
        field.delegate = self
        field.onFieldClicked { self.delegate?.onBillingPressed() }
        field.translatesAutoresizingMaskIntoConstraints = false
        return field
    }()
    
    private lazy var editButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.applyWithImage(style: .redesignStyle, title: "expand.edit.account.title".localized())
        button.addTarget(self, action: #selector(editButtonPressed), for: .touchUpInside)
        return button
    }()
    
    override init() {
        super.init()
        title = "expand.edit.account.title".localized()
        setUpScrollContainerViewConstraints()
        setUpPaymentCardFieldConstraints()
        setUpCardNumberFieldConstraints()
        setUpCardExpCardCvvFieldsConstraints()
        setUpCardHolderNameFieldConstraints()
        setUpFromToTimeCreatedFieldsConstraints()
        setUpBillingAddressFieldConstraints()
        setUpEditButtonConstraints()
        
        setUpSeparatorBottomLineConstraints(containerView, belowView: editButton)
        setUpCodeResponseViewConstraints(containerView)
        setUpDataExampleCode()
        
        setUpLoadingViewConstraints()
    }
    
    private func setUpDataExampleCode() {
        codeResponseView.locationLabel = "Modules/Merchant/Edit/"
        codeResponseView.fileLabel = "MerchantEditViewModel.swift"
        codeResponseView.titleResponseDataView = "EditAccountInfo"
        codeResponseView.exampleCodeImage = #imageLiteral(resourceName: "edit_account_code")
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
    
    private func setUpPaymentCardFieldConstraints() {
        containerView.addSubview(paymentCardFieldView)
        NSLayoutConstraint.activating([
            paymentCardFieldView.relativeTo(containerView, positioned: .top() + .width())
        ])
    }
    
    private func setUpCardNumberFieldConstraints() {
        containerView.addSubview(cardNumberFieldView)
        NSLayoutConstraint.activating([
            cardNumberFieldView.relativeTo(paymentCardFieldView, positioned: .belowWidth(spacing: DimensKeys.marginMedium))
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
    
    private func setUpFromToTimeCreatedFieldsConstraints() {
        containerView.addSubview(fromToTimeCreatedFieldsView)
        NSLayoutConstraint.activating([
            fromToTimeCreatedFieldsView.relativeTo(cardHolderNameFieldView, positioned: .belowWidth(spacing: DimensKeys.marginMedium))
        ])
    }
    
    private func setUpBillingAddressFieldConstraints() {
        containerView.addSubview(billingAddressFieldView)
        NSLayoutConstraint.activating([
            billingAddressFieldView.relativeTo(fromToTimeCreatedFieldsView, positioned: .belowWidth(spacing: DimensKeys.marginMedium))
        ])
    }
    
    private func setUpEditButtonConstraints() {
        containerView.addSubview(editButton)
        NSLayoutConstraint.activating([
            editButton.relativeTo(billingAddressFieldView, positioned: .belowWidth(spacing: DimensKeys.marginMedium)),
            editButton.constrainedBy(.constantHeight(DimensKeys.buttonSize))
        ])
    }
    
    func defaultValues() {
        onChangePaymentCard(name: PaymentCardModel.models.first?.name ?? "")
    }
    
    @objc func editButtonPressed() {
        delegate?.onEditAccount()
    }
    
    func enableButton(_ enable: Bool) {
        editButton.isEnabled = enable
        editButton.alpha = enable ? DimensKeys.enabledButton : DimensKeys.disabledButton
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
    
    private func datePicker(_ type: GpFieldsEnum) -> UIDatePicker{
        let datePickerView = UIDatePicker()
        datePickerView.tag = type.rawValue
        datePickerView.datePickerMode = .date
        if #available(iOS 14, *) {
            datePickerView.preferredDatePickerStyle = .inline
        }
        datePickerView.addTarget(self, action: #selector(handleChange(sender:)), for: .valueChanged)
        return datePickerView
    }
    
    @objc func handleChange(sender: UIDatePicker){
        let dateFormatter = DateFormatter()
        
        switch sender.tag {
        case GpFieldsEnum.fromTimeCreated.rawValue:
            dateFormatter.dateFormat = "dd-MMM-yyyy"
            fromToTimeCreatedFieldsView.firstText = dateFormatter.string(from: sender.date)
        case GpFieldsEnum.toTimeCreated.rawValue:
            dateFormatter.dateFormat = "dd-MMM-yyyy"
            fromToTimeCreatedFieldsView.secondText = dateFormatter.string(from: sender.date)
        case GpFieldsEnum.expirationDate.rawValue:
            dateFormatter.dateFormat = "MM/yyyy"
            cardExpCardCvvFieldsView.firstText = dateFormatter.string(from: sender.date)
        default:
            break
        }
    }
    
    func setBillingLabel(_ value: String) {
        billingAddressFieldView.text = value
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
}

extension MerchantEditView: GpTextFieldDelegate {
    
    func textChanged(value: String, type: GpFieldsEnum) {
        delegate?.fieldDataChanged(value: value, type: type)
    }
}
