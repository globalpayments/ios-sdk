import UIKit
import GlobalPayments_iOS_SDK

protocol AccountByIdViewDelegate: AnyObject {
    func fieldDataChanged(value: String, type: GpFieldsEnum)
    func onSubmitButtonPressed()
}

final class AccountByIdView: GpBaseSingleView {
    
    private let idDefault = "MER_98f60f1a397c4dd7b7167bda61520292"
    
    weak var delegate: AccountByIdViewDelegate?
    
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
        field.titleMandatory = "reporting.account.id.label".localized()
        field.delegate = self
        field.tagField = .accountId
        field.translatesAutoresizingMaskIntoConstraints = false
        return field
    }()
    
    private lazy var submitButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.applyWithImage(style: .redesignStyle, title: "reporting.account.get.account.id.button".localized().uppercased())
        button.addTarget(self, action: #selector(submitButtonPressed), for: .touchUpInside)
        return button
    }()
    
    override init() {
        super.init()
        separatorLineView.backgroundColor = .clear
        setUpScrollContainerViewConstraints()
        setUpIdFieldConstraints()
        setUpChargeButtonConstraints()
        
        setUpSeparatorBottomLineConstraints(containerView, belowView: submitButton)
        setUpCodeResponseViewConstraints(containerView)
        setUpDataExampleCode()
        
        setUpLoadingViewConstraints()
    }
    
    private func setUpDataExampleCode() {
        codeResponseView.locationLabel = "Modules/Accounts/AccountsReport"
        codeResponseView.fileLabel = "AccountByIdViewModel.swift"
        codeResponseView.titleResponseDataView = "AccountById"
        codeResponseView.exampleCodeImage = #imageLiteral(resourceName: "reporting_account_id_code")
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
    
    private func setUpChargeButtonConstraints() {
        containerView.addSubview(submitButton)
        NSLayoutConstraint.activating([
            submitButton.relativeTo(idFieldView, positioned: .belowWidth(spacing: DimensKeys.marginMedium, margin: DimensKeys.marginMedium)),
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
    }
    
    @objc func submitButtonPressed() {
        delegate?.onSubmitButtonPressed()
    }
}

extension AccountByIdView: GpTextFieldDelegate {
    
    func textChanged(value: String, type: GpFieldsEnum) {
        delegate?.fieldDataChanged(value: value, type: type)
    }
}
