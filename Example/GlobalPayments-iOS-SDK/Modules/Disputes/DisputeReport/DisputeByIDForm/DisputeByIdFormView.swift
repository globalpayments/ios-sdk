import UIKit
import GlobalPayments_iOS_SDK

protocol DisputeByIdFormViewDelegate: AnyObject {
    func fieldDataChanged(value: String, type: GpFieldsEnum)
    func onSubmitButtonPressed()
    func setFromSettlements(_ value: Bool)
}

final class DisputeByIdFormView: GpBaseSingleView {
    
    private let idDefault = "DIS_SAND_abcd1235"
    
    weak var delegate: DisputeByIdFormViewDelegate?
    
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
        field.titleMandatory = "reporting.disputes.id.label".localized()
        field.delegate = self
        field.tagField = .disputeId
        field.translatesAutoresizingMaskIntoConstraints = false
        return field
    }()
    
    private lazy var getSettlementsSwitch: GpLabelSwitchView = {
        let switchButton = GpLabelSwitchView()
        switchButton.addAction(self, selector: #selector(onSwitchValueChanged(_:)))
        switchButton.title = "Get from settlements?"
        switchButton.translatesAutoresizingMaskIntoConstraints = false
        return switchButton
    }()
    
    private lazy var submitButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.applyWithImage(style: .redesignStyle, title: "reporting.disputes.get.action.by.id.button".localized().uppercased())
        button.addTarget(self, action: #selector(submitButtonPressed), for: .touchUpInside)
        return button
    }()
    
    override init() {
        super.init()
        separatorLineView.backgroundColor = .clear
        setUpScrollContainerViewConstraints()
        setUpIdFieldConstraints()
        setUpSettlementsSwitchConstraints()
        setUpChargeButtonConstraints()
        
        setUpSeparatorBottomLineConstraints(containerView, belowView: submitButton)
        setUpCodeResponseViewConstraints(containerView)
        setUpDataExampleCode()
        
        setUpLoadingViewConstraints()
    }
    
    private func setUpDataExampleCode() {
        codeResponseView.locationLabel = "Modules/Disputes/DisputeReport"
        codeResponseView.fileLabel = "DisputeByIdFormViewModel.swift"
        codeResponseView.titleResponseDataView = "DisputeById"
        codeResponseView.exampleCodeImage = #imageLiteral(resourceName: "reporting_dispute_list_code")
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
    
    private func setUpSettlementsSwitchConstraints() {
        containerView.addSubview(getSettlementsSwitch)
        NSLayoutConstraint.activating([
            getSettlementsSwitch.relativeTo(idFieldView, positioned: .belowWidth(spacing: DimensKeys.marginMedium))
        ])
    }
    
    private func setUpChargeButtonConstraints() {
        containerView.addSubview(submitButton)
        NSLayoutConstraint.activating([
            submitButton.relativeTo(getSettlementsSwitch, positioned: .belowWidth(spacing: DimensKeys.marginMedium, margin: DimensKeys.marginMedium)),
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
    
    @objc private func onSwitchValueChanged(_ switchButton: UISwitch) {
        delegate?.setFromSettlements(switchButton.isOn)
    }
}

extension DisputeByIdFormView: GpTextFieldDelegate {
    
    func textChanged(value: String, type: GpFieldsEnum) {
        delegate?.fieldDataChanged(value: value, type: type)
    }
}
