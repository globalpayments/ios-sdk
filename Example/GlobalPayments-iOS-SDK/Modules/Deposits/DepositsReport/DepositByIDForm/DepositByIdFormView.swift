import UIKit
import GlobalPayments_iOS_SDK

protocol DepositByIdFormViewDelegate: AnyObject {
    func fieldDataChanged(value: String, type: GpFieldsEnum)
    func onSubmitButtonPressed()
}

final class DepositByIdFormView: GpBaseSingleView {
    
    private let idDefault = "DEP_2342423423"
    
    weak var delegate: DepositByIdFormViewDelegate?
    
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
        field.titleMandatory = "reporting.deposits.view.id.title".localized()
        field.delegate = self
        field.tagField = .depositId
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
        setUpChargeButtonConstraints()
        
        setUpSeparatorBottomLineConstraints(containerView, belowView: submitButton)
        setUpCodeResponseViewConstraints(containerView)
        setUpDataExampleCode()
        
        setUpLoadingViewConstraints()
    }
    
    private func setUpDataExampleCode() {
        codeResponseView.locationLabel = "Modules/Deposits/DepositsReport"
        codeResponseView.fileLabel = "DepositByIdViewModel.swift"
        codeResponseView.titleResponseDataView = "DepositById"
        codeResponseView.exampleCodeImage = #imageLiteral(resourceName: "reporting_deposit_id_code")
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

extension DepositByIdFormView: GpTextFieldDelegate {
    
    func textChanged(value: String, type: GpFieldsEnum) {
        delegate?.fieldDataChanged(value: value, type: type)
    }
}
