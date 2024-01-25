import UIKit
import GlobalPayments_iOS_SDK

protocol VerificationsFormViewDelegate: AnyObject {
    func onSubmitPressed()
    func fieldDataChanged(value: String, type: GpFieldsEnum)
}

class VerificationsFormView: GpBaseView {
    
    private var fingerprintFieldConstraint: NSLayoutConstraint?
    
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
        title = "verifications.form.title".localized()
        setUpScrollContainerViewConstraints()
        setUpPaymentCardFieldConstraints()
        setUpCardNumberFieldConstraints()
        setUpCardExpCardCvvFieldsConstraints()
        setUpCurrencyFieldConstraints()
        setUpStoredPaymentButtonConstraints()
        
        setUpSeparatorBottomLineConstraints(containerView, belowView: storedPaymentButton)
        setUpCodeResponseViewConstraints(containerView)
        setUpDataExampleCode()
        
        setUpLoadingViewConstraints()
    }
    
    private func setUpDataExampleCode() {
        codeResponseView.locationLabel = "Modules/Verifications"
        codeResponseView.fileLabel = "VerificationsFormViewModel.swift"
        codeResponseView.titleResponseDataView = "VerificationsFormInfo"
        codeResponseView.exampleCodeImage = #imageLiteral(resourceName: "verifications_code")
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
            cardNumberFieldView.relativeTo(paymentCardFieldView, positioned:.belowWidth(spacing: DimensKeys.marginMedium))
        ])
    }
    
    private func setUpCardExpCardCvvFieldsConstraints() {
        containerView.addSubview(cardExpCardCvvFieldsView)
        
        NSLayoutConstraint.activating([
            cardExpCardCvvFieldsView.relativeTo(cardNumberFieldView, positioned:.belowWidth(spacing: DimensKeys.marginMedium))
        ])
    }
    
    private func setUpCurrencyFieldConstraints() {
        containerView.addSubview(currencyFieldView)
        
        NSLayoutConstraint.activating([
            currencyFieldView.relativeTo(cardExpCardCvvFieldsView, positioned:.belowWidth(spacing: DimensKeys.marginMedium))
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
        currencyFieldView.text = Currency.USD.rawValue
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
}

extension VerificationsFormView: GpTextFieldDelegate {
    
    func textChanged(value: String, type: GpFieldsEnum) {
        delegate?.fieldDataChanged(value: value, type: type)
    }
}
