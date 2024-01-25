import UIKit
import GlobalPayments_iOS_SDK

protocol PaymentMethodByIdViewDelegate: AnyObject {
    func fieldDataChanged(value: String, type: GpFieldsEnum)
    func onSubmitButtonPressed()
}

final class PaymentMethodByIdView: GpBaseSingleView {
    
    private let idDefault = "PMT_d312d131-0ef4-4c1a-aec9-f632fdf3da00"
    private let currencyDefault = "USD"
    
    weak var delegate: PaymentMethodByIdViewDelegate?
    
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
    
    private lazy var idFieldView: GpTextFieldView = {
        let field = GpTextFieldView()
        field.titleMandatory = "payment.methods.report.id.payment.method".localized()
        field.delegate = self
        field.tagField = .paymentMethodId
        field.translatesAutoresizingMaskIntoConstraints = false
        return field
    }()
    
    private lazy var currencyFieldView: GpTextFieldView = {
        let field = GpTextFieldView()
        field.titleMandatory = "deposits.currency".localized()
        field.delegate = self
        field.tagField = .currency
        field.translatesAutoresizingMaskIntoConstraints = false
        return field
    }()
    
    private lazy var submitButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.applyWithImage(style: .redesignStyle, title: "deposits.get.deposit.by.id".localized().uppercased())
        button.addTarget(self, action: #selector(submitButtonPressed), for: .touchUpInside)
        return button
    }()
    
    override init() {
        super.init()
        separatorLineView.backgroundColor = .clear
        setUpScrollContainerViewConstraints()
        setUpIdFieldConstraints()
        setUpCurrencyFieldConstraints()
        setUpChargeButtonConstraints()
        
        setUpSeparatorBottomLineConstraints(containerView, belowView: submitButton)
        setUpCodeResponseViewConstraints(containerView)
        setUpDataExampleCode()
        
        setUpLoadingViewConstraints()
    }
    
    private func setUpDataExampleCode() {
        codeResponseView.locationLabel = "Modules/StoredPaymentMethods/PaymentMethodReport"
        codeResponseView.fileLabel = "PaymentMethodByIDViewModel.swift"
        codeResponseView.titleResponseDataView = "PaymentMethodById"
        codeResponseView.exampleCodeImage = #imageLiteral(resourceName: "reporting_payment_method_id_code")
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
    
    private func setUpIdFieldConstraints() {
        containerView.addSubview(idFieldView)
        NSLayoutConstraint.activating([
            idFieldView.relativeTo(containerView, positioned: .top() + .width())
        ])
    }
    
    private func setUpCurrencyFieldConstraints() {
        containerView.addSubview(currencyFieldView)
        NSLayoutConstraint.activating([
            currencyFieldView.relativeTo(idFieldView, positioned: .belowWidth(spacing: DimensKeys.marginMedium))
        ])
    }
    
    private func setUpChargeButtonConstraints() {
        containerView.addSubview(submitButton)
        NSLayoutConstraint.activating([
            submitButton.relativeTo(currencyFieldView, positioned: .belowWidth(spacing: DimensKeys.marginMedium, margin: DimensKeys.marginMedium)),
            submitButton.constrainedBy(.constantHeight(DimensKeys.buttonSize))
        ])
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
    
    func defaultValues() {
        idFieldView.text = idDefault
        currencyFieldView.text = currencyDefault
    }
    
    @objc func submitButtonPressed() {
        delegate?.onSubmitButtonPressed()
    }
}

extension PaymentMethodByIdView: GpTextFieldDelegate {
    
    func textChanged(value: String, type: GpFieldsEnum) {
        delegate?.fieldDataChanged(value: value, type: type)
    }
}

