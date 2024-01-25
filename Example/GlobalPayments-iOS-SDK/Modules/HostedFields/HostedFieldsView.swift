import UIKit
import GlobalPayments_iOS_SDK

protocol HostedFieldsViewDelegate: AnyObject {
    func fieldDataChanged(value: String, type: GpFieldsEnum)
    func onHostedFieldsTokenError(_ message: String)
    func onSubmitAction()
    func onTokenizedSuccess(token: String, cardBrand: String)
}

final class HostedFieldsView: GpBaseView {
    
    private let defaultAmount = "10.01"
    
    private struct DimensKeys {
        static let margin: CGFloat = 10
        static let marginSmall: CGFloat = 5
        static let marginMedium: CGFloat = 15
        static let marginBig: CGFloat = 20
    }
    
    weak var delegate: HostedFieldsViewDelegate?
    
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
    
    private lazy var supportView: UIView = {
        let container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false
        let borderColor = #colorLiteral(red: 0.8235294118, green: 0.8470588235, blue: 0.8823529412, alpha: 1)
        container.cornersBorder(borderColor: borderColor)
        container.backgroundColor = #colorLiteral(red: 0.9882352941, green: 0.9882352941, blue: 0.9882352941, alpha: 1)
        return container
    }()
    
    override init() {
        super.init()
        title = "globalpay.hosted.fields.title".localized()
        descriptionValue = "hosted.fields.description".localized()
        
        setUpScrollContainerViewConstraints()
        setUpAmountFieldConstraints()
        setUpSupportViewConstraints()
        
        setUpSeparatorBottomLineConstraints(containerView, belowView: supportView)
        setUpCodeResponseViewConstraints(containerView)
        setUpDataExampleCode()
        
        setUpLoadingViewConstraints()
    }
    
    private func setUpDataExampleCode() {
        codeResponseView.locationLabel = "Modules/HostedFields/"
        codeResponseView.fileLabel = "HostedFieldsViewModel.swift"
        codeResponseView.titleResponseDataView = "HostedFieldsInfo"
        codeResponseView.exampleCodeImage = #imageLiteral(resourceName: "hosted_fields_code")
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
    
    private func setUpSupportViewConstraints() {
        containerView.addSubview(supportView)
        NSLayoutConstraint.activating([
            supportView.relativeTo(containerView, positioned: .width()),
            supportView.relativeTo(amountFieldView, positioned: .below(spacing: DimensKeys.marginMedium) + .constantHeight(600)),
        ])
    }
    
    func showHostedFields(_ token: String?) {
        let hostedFieldsWebView = HostedFieldsWebView.instantiateFromNib(token ?? "")
        hostedFieldsWebView.delegate = self
        hostedFieldsWebView.translatesAutoresizingMaskIntoConstraints = false
        supportView.addSubview(hostedFieldsWebView)
        NSLayoutConstraint.activating([
            hostedFieldsWebView.relativeTo(supportView, positioned: .allAnchors(padding: DimensKeys.marginSmall) + .centerX())
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
}

extension HostedFieldsView: GpTextFieldDelegate {
    
    func textChanged(value: String, type: GpFieldsEnum) {
        delegate?.fieldDataChanged(value: value, type: type)
    }
}

extension HostedFieldsView: HostedFieldsWebViewOutput {
    
    func onTokenError(_ message: String) {
        delegate?.onHostedFieldsTokenError(message)
    }
    
    func onTokenizedSuccess(token: String, cardBrand: String) {
        delegate?.onTokenizedSuccess(token: token, cardBrand: cardBrand)
    }
    
    func onSubmitAction() {
        delegate?.onSubmitAction()
    }
}
