import UIKit
import GlobalPayments_iOS_SDK

protocol AliPayViewDelegate: AnyObject {
    func onChargePressed()
    func fieldDataChanged(value: String, type: GpFieldsEnum)
}

class AliPayView: GpBaseView {
    
    private let defaultAmount = "19.99"
    
    private struct DimensKeys {
        static let logoMargin: CGFloat = 20
        static let marginTop: CGFloat = 20
        static let marginSide: CGFloat = 20
        static let marginSmall: CGFloat = 5
        static let marginMedium: CGFloat = 15
        static let marginBig: CGFloat = 20
        static let buttonSize: CGFloat = 48.0
    }
    
    weak var delegate: AliPayViewDelegate?
    
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
    
    override init() {
        super.init()
        title = "globalpay.alipay.title".localized()
        setUpScrollContainerViewConstraints()
        setUpAmountFieldConstraints()
        setUpCardHolderNameFieldConstraints()
        setUpChargeButtonConstraints()
        
        setUpSeparatorBottomLineConstraints(containerView, belowView: chargeButton)
        setUpCodeResponseViewConstraints(containerView)
        setUpDataExampleCode()
        
        setUpLoadingViewConstraints()
    }
    
    private func setUpDataExampleCode() {
        codeResponseView.locationLabel = "Modules/AliPay"
        codeResponseView.fileLabel = "AliPayViewModel.swift"
        codeResponseView.titleResponseDataView = "AliPayInfo"
        codeResponseView.exampleCodeImage = #imageLiteral(resourceName: "ali_pay_code")
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
    
    private func setUpCardHolderNameFieldConstraints() {
        containerView.addSubview(cardHolderNameField)
        NSLayoutConstraint.activating([
            cardHolderNameField.relativeTo(amountFieldView, positioned: .belowWidth(spacing: DimensKeys.marginMedium))
        ])
    }
    
    private func setUpChargeButtonConstraints() {
        containerView.addSubview(chargeButton)
        NSLayoutConstraint.activating([
            chargeButton.relativeTo(cardHolderNameField, positioned: .belowWidth(spacing: DimensKeys.marginMedium, margin: DimensKeys.marginSide)),
            chargeButton.constrainedBy(.constantHeight(DimensKeys.buttonSize))
        ])
    }
    
    func defaultValues() {
        amountFieldView.text = defaultAmount
        cardHolderNameField.text = "Jane Doe"
    }
    
    @objc func chargeButtonPressed() {
        delegate?.onChargePressed()
    }
    
    func toBottomView() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.moveToBottomView()
        }
    }
    
    private func moveToBottomView() {
        let bottomOffset = CGPoint(x: 0, y: scrollContainerView.contentSize.height - containerView.bounds.height + scrollContainerView.contentInset.bottom)
        scrollContainerView.setContentOffset(bottomOffset, animated: true)
    }
}

extension AliPayView: GpTextFieldDelegate {
    
    func textChanged(value: String, type: GpFieldsEnum) {
        delegate?.fieldDataChanged(value: value, type: type)
    }
}
