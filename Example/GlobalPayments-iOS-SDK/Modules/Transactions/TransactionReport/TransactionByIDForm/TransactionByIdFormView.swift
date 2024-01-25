import UIKit
import GlobalPayments_iOS_SDK

protocol TransactionByIdFormViewDelegate: AnyObject {
    func fieldDataChanged(value: String, type: GpFieldsEnum)
    func onSubmitButtonPressed()
}

final class TransactionByIdFormView: GpBaseSingleView {
    
    private let transactionIdExample = "TRN_7g3faeVD43hkwAQ44k5vgTzl4tb1Ep"
    
    weak var delegate: TransactionByIdFormViewDelegate?
    
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
    
    private lazy var transactionIdFieldView: GpTextFieldView = {
        let field = GpTextFieldView()
        field.titleMandatory = "transaction.report.by.id.form".localized()
        field.delegate = self
        field.tagField = .transactionId
        field.translatesAutoresizingMaskIntoConstraints = false
        return field
    }()
    
    private lazy var submitButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.applyWithImage(style: .redesignStyle, title: "reporting.transaction.view.button.title".localized().uppercased())
        button.addTarget(self, action: #selector(submitButtonPressed), for: .touchUpInside)
        return button
    }()
    
    override init() {
        super.init()
        separatorLineView.backgroundColor = .clear
        setUpScrollContainerViewConstraints()
        setUpTransactionsIdFieldConstraints()
        setUpChargeButtonConstraints()
        
        setUpSeparatorBottomLineConstraints(containerView, belowView: submitButton)
        setUpCodeResponseViewConstraints(containerView)
        setUpDataExampleCode()
        
        setUpLoadingViewConstraints()
    }
    
    private func setUpDataExampleCode() {
        codeResponseView.locationLabel = "Modules/Transactions/TransactionReport"
        codeResponseView.fileLabel = "TransactionByIdViewModel.swift"
        codeResponseView.titleResponseDataView = "TransactionById"
        codeResponseView.exampleCodeImage = #imageLiteral(resourceName: "reporting_transaction_id_code")
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
    
    private func setUpTransactionsIdFieldConstraints() {
        containerView.addSubview(transactionIdFieldView)
        NSLayoutConstraint.activating([
            transactionIdFieldView.relativeTo(containerView, positioned: .top() + .width())
        ])
    }
    
    private func setUpChargeButtonConstraints() {
        containerView.addSubview(submitButton)
        NSLayoutConstraint.activating([
            submitButton.relativeTo(transactionIdFieldView, positioned: .belowWidth(spacing: DimensKeys.marginMedium, margin: DimensKeys.marginMedium)),
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
        transactionIdFieldView.text = transactionIdExample
    }
    
    @objc func submitButtonPressed() {
        delegate?.onSubmitButtonPressed()
    }
}

extension TransactionByIdFormView: GpTextFieldDelegate {
    
    func textChanged(value: String, type: GpFieldsEnum) {
        delegate?.fieldDataChanged(value: value, type: type)
    }
}

