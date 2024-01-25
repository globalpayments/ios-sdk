import UIKit
import GlobalPayments_iOS_SDK

protocol BatchViewDelegate: AnyObject {
    func onCloseBatchButtonPressed()
    func fieldDataChanged(value: String, type: GpFieldsEnum)
}

class BatchView: GpBaseView {
    
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
    
    weak var delegate: BatchViewDelegate?
    
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
    
    private lazy var batchIdFieldView: GpTextFieldView = {
        let field = GpTextFieldView()
        field.titleMandatory = "transaction.report.by.id.id".localized()
        field.delegate = self
        field.tagField = .batchId
        field.translatesAutoresizingMaskIntoConstraints = false
        return field
    }()
    
    private lazy var closeBatchButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.applyWithImage(style: .redesignStyle, title: "expand.batches.close.button.title".localized())
        button.addTarget(self, action: #selector(closeBatchButtonPressed), for: .touchUpInside)
        return button
    }()
    
    override init() {
        super.init()
        title = "expand.batches.title".localized()
        setUpScrollContainerViewConstraints()
        setUpBatchIdFieldConstraints()
        setUpCloseBatchButtonConstraints()
        
        setUpSeparatorBottomLineConstraints(containerView, belowView: closeBatchButton)
        setUpCodeResponseViewConstraints(containerView)
        setUpDataExampleCode()
        
        setUpLoadingViewConstraints()
    }
    
    private func setUpDataExampleCode() {
        codeResponseView.locationLabel = "Modules/Batch/"
        codeResponseView.fileLabel = "BatchViewModel.swift"
        codeResponseView.titleResponseDataView = "BatchInfo"
        codeResponseView.exampleCodeImage = #imageLiteral(resourceName: "batch_code")
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
    
    private func setUpBatchIdFieldConstraints() {
        containerView.addSubview(batchIdFieldView)
        NSLayoutConstraint.activating([
            batchIdFieldView.relativeTo(containerView, positioned: .top() + .width())
        ])
    }
    
    private func setUpCloseBatchButtonConstraints() {
        containerView.addSubview(closeBatchButton)
        NSLayoutConstraint.activating([
            closeBatchButton.relativeTo(batchIdFieldView, positioned: .belowWidth(spacing: DimensKeys.marginMedium)),
            closeBatchButton.constrainedBy(.constantHeight(DimensKeys.buttonSize))
        ])
    }
    
    func defaultValues() {
        batchIdFieldView.text = defaultBatch
    }
    
    @objc func closeBatchButtonPressed() {
        delegate?.onCloseBatchButtonPressed()
    }
    
    func enableButton(_ enable: Bool) {
        closeBatchButton.isEnabled = enable
        closeBatchButton.alpha = enable ? DimensKeys.enabledButton : DimensKeys.disabledButton
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

extension BatchView: GpTextFieldDelegate {
    
    func textChanged(value: String, type: GpFieldsEnum) {
        delegate?.fieldDataChanged(value: value, type: type)
    }
}


