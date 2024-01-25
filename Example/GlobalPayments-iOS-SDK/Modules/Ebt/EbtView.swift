import UIKit
import GlobalPayments_iOS_SDK

protocol EbtViewDelegate: AnyObject {
    func onChargePressed()
    func onRefundPressed()
    func fieldDataChanged(value: String, type: GpFieldsEnum)
}

class EbtView: GpBaseView {
    
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
    
    weak var delegate: EbtViewDelegate?
    
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
    
    private lazy var cardNumberField: GpTextFieldView = {
        let field = GpTextFieldView()
        field.title = "transactoin.operations.form.card.number".localized()
        field.tagField = .cardNumber
        field.inputMode = .numberPad
        field.delegate = self
        field.translatesAutoresizingMaskIntoConstraints = false
        return field
    }()
    
    private lazy var expirationDateFieldView: GpTextFieldView = {
        let field = GpTextFieldView()
        field.titleMandatory = "payment.process.expiration.date.tittle".localized()
        field.tagField = .expirationDate
        field.setDateDropDown(format: "MM-yyyy")
        field.delegate = self
        field.translatesAutoresizingMaskIntoConstraints = false
        return field
    }()
    
    private lazy var pinBlockField: GpTextFieldView = {
        let field = GpTextFieldView()
        field.title = "ebt.pin.block.title".localized()
        field.tagField = .pinBlock
        field.delegate = self
        field.translatesAutoresizingMaskIntoConstraints = false
        return field
    }()
    
    private lazy var cvnField: GpTextFieldView = {
        let field = GpTextFieldView()
        field.title = "transactoin.operations.form.cvn.cvv".localized()
        field.tagField = .cardCvv
        field.inputMode = .numberPad
        field.delegate = self
        field.translatesAutoresizingMaskIntoConstraints = false
        return field
    }()
    
    private lazy var cardHolderNameField: GpTextFieldView = {
        let field = GpTextFieldView()
        field.title = "check.availability.form.card.holder.name".localized()
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
        title = "globalpay.ebt.title".localized()
        setUpScrollContainerViewConstraints()
        setUpAmountFieldConstraints()
        setUpCardNumberFieldConstraints()
        setUpExpirationDateFieldConstraints()
        setUpPinBlockFieldConstraints()
        setUpCvnFieldConstraints()
        setUpCardHolderNameFieldConstraints()
        setUpChargeButtonConstraints()
        setUpRefundButtonConstraints()
        
        setUpSeparatorBottomLineConstraints(containerView, belowView: refundButton)
        setUpCodeResponseViewConstraints(containerView)
        setUpDataExampleCode()
        
        setUpLoadingViewConstraints()
    }
    
    private func setUpDataExampleCode() {
        codeResponseView.locationLabel = "Modules/Ebt/"
        codeResponseView.fileLabel = "EbtViewModel.swift"
        codeResponseView.titleResponseDataView = "EbtInfo"
        codeResponseView.exampleCodeImage = #imageLiteral(resourceName: "ebt_code")
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
    
    private func setUpCardNumberFieldConstraints() {
        containerView.addSubview(cardNumberField)
        NSLayoutConstraint.activating([
            cardNumberField.relativeTo(amountFieldView, positioned: .belowWidth(spacing: DimensKeys.marginMedium))
        ])
    }
    
    private func setUpExpirationDateFieldConstraints() {
        containerView.addSubview(expirationDateFieldView)
        NSLayoutConstraint.activating([
            expirationDateFieldView.relativeTo(cardNumberField, positioned: .belowWidth(spacing: DimensKeys.marginMedium))
        ])
    }
    
    private func setUpPinBlockFieldConstraints() {
        containerView.addSubview(pinBlockField)
        NSLayoutConstraint.activating([
            pinBlockField.relativeTo(expirationDateFieldView, positioned: .belowWidth(spacing: DimensKeys.marginMedium))
        ])
    }
    
    private func setUpCvnFieldConstraints() {
        containerView.addSubview(cvnField)
        NSLayoutConstraint.activating([
            cvnField.relativeTo(pinBlockField, positioned: .belowWidth(spacing: DimensKeys.marginMedium))
        ])
    }
    
    private func setUpCardHolderNameFieldConstraints() {
        containerView.addSubview(cardHolderNameField)
        NSLayoutConstraint.activating([
            cardHolderNameField.relativeTo(cvnField, positioned: .belowWidth(spacing: DimensKeys.marginMedium))
        ])
    }
    
    private func setUpChargeButtonConstraints() {
        containerView.addSubview(chargeButton)
        NSLayoutConstraint.activating([
            chargeButton.relativeTo(cardHolderNameField, positioned: .belowWidth(spacing: DimensKeys.marginMedium, margin: DimensKeys.marginSide)),
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
        cardNumberField.text = "4012002000060016"
        pinBlockField.text = "32539F50C245A6A93D123412324000AA"
        cvnField.text = "123"
        cardHolderNameField.text = "Joe Doe"
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

extension EbtView: GpTextFieldDelegate {
    
    func textChanged(value: String, type: GpFieldsEnum) {
        delegate?.fieldDataChanged(value: value, type: type)
    }
}


