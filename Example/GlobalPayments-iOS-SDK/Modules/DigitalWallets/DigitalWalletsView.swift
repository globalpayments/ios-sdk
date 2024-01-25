import UIKit
import PassKit

protocol DigitalWalletsViewDelegate: AnyObject {
    func onApplePayButtonAction()
    func fieldDataChanged(value: String, type: GpFieldsEnum)
}

class DigitalWalletsView: GpBaseView {
    
    private let defaultAmount = "10.01"
    
    private struct DimensKeys {
        static let marginTop: CGFloat = 20
        static let marginSide: CGFloat = 20
        static let marginSmall: CGFloat = 5
        static let marginMedium: CGFloat = 15
        static let sizeHeightButton: CGFloat = 50
    }
    
    weak var delegate: DigitalWalletsViewDelegate?
    
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
    
    private lazy var applePayButton: PKPaymentButton = {
        let button = PKPaymentButton(paymentButtonType: .buy, paymentButtonStyle: .black)
        button.setOnClickListener {
            self.delegate?.onApplePayButtonAction()
        }
        button.setCorners(DimensKeys.sizeHeightButton / 2)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    override init() {
        super.init()
        title = "globalpay.apple.pay".localized()
        setUpScrollContainerViewConstraints()
        setUpAmountFieldConstraints()
        setUpApplePayButtonConstraints()
        
        setUpSeparatorBottomLineConstraints(containerView, belowView: applePayButton)
        setUpCodeResponseViewConstraints(containerView)
        setUpDataExampleCode()
        
        setUpLoadingViewConstraints()
    }
    
    private func setUpDataExampleCode() {
        codeResponseView.locationLabel = "Modules/DigitalWallets/"
        codeResponseView.fileLabel = "DigitalWalletsViewModel.swift"
        codeResponseView.titleResponseDataView = "ApplePayInfo"
        codeResponseView.exampleCodeImage = #imageLiteral(resourceName: "apple_pay_code")
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
    
    private func setUpApplePayButtonConstraints() {
        containerView.addSubview(applePayButton)
        NSLayoutConstraint.activating([
            applePayButton.relativeTo(amountFieldView, positioned: .belowWidth(spacing: DimensKeys.marginMedium, margin: DimensKeys.marginSide) + .constantHeight(DimensKeys.sizeHeightButton))
        ])
    }
    
    func defaultValues() {
        amountFieldView.text = defaultAmount
    }
}

extension DigitalWalletsView: GpTextFieldDelegate {
    
    func textChanged(value: String, type: GpFieldsEnum) {
        delegate?.fieldDataChanged(value: value, type: type)
    }
}
