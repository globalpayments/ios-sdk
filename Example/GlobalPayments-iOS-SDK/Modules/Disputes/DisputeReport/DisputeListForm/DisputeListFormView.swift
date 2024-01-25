import UIKit
import GlobalPayments_iOS_SDK

protocol DisputeListFormViewDelegate: AnyObject {
    func fieldDataChanged(value: String, type: GpFieldsEnum)
    func onSubmitButtonPressed()
    func setFromSettlements(_ value: Bool)
}

final class DisputeListFormView: GpBaseSingleView {
    
    weak var delegate: DisputeListFormViewDelegate?
    private var moreFieldsShowed = false
    
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
    
    private lazy var getSettlementsSwitch: GpLabelSwitchView = {
        let switchButton = GpLabelSwitchView()
        switchButton.addAction(self, selector: #selector(onSwitchValueChanged(_:)))
        switchButton.title = "Get from settlements?"
        switchButton.translatesAutoresizingMaskIntoConstraints = false
        return switchButton
    }()
    
    private lazy var pageAndPageSizeFieldsView: GpDoubleFieldView = {
        let fields = GpDoubleFieldView()
        fields.translatesAutoresizingMaskIntoConstraints = false
        fields.firstTitle = "transaction.report.list.page".localized()
        fields.secondTitle = "deposits.list.form.page.size".localized()
        
        fields.setFirstTagField(.page, delegate: self)
        fields.setSecondTagField(.pageSize, delegate: self)
        return fields
    }()
    
    private lazy var orderAndOrderByFieldsView: GpDoubleFieldView = {
        let fields = GpDoubleFieldView()
        fields.translatesAutoresizingMaskIntoConstraints = false
        fields.firstTitle = "deposits.list.form.order".localized()
        fields.secondTitle = "deposits.list.form.order.by".localized()
        let orderDirection = SortDirection.allCases.map { $0.rawValue.uppercased() }
        let orderByTypes = DisputeSortProperty.allCases.map { $0.rawValue.uppercased() }
        fields.setDropDownBoth(orderDirection, secondData: orderByTypes)
        fields.setFirstTagField(.order, delegate: self)
        fields.setSecondTagField(.orderBy, delegate: self)
        return fields
    }()
    
    private lazy var statusFieldView: GpTextFieldView = {
        let field = GpTextFieldView()
        field.title = "Status:"
        field.delegate = self
        field.tagField = .status
        let disputeStatusData = ["NONE"] + DisputeStatus.allCases.map { $0.rawValue.uppercased() }
        field.setDropDown(disputeStatusData)
        field.translatesAutoresizingMaskIntoConstraints = false
        return field
    }()
    
    private lazy var systemMIDFieldView: GpTextFieldView = {
        let field = GpTextFieldView()
        field.title = "System MID:"
        field.delegate = self
        field.tagField = .systemMid
        field.translatesAutoresizingMaskIntoConstraints = false
        return field
    }()
    
    private lazy var systemHierarchyFieldView: GpTextFieldView = {
        let field = GpTextFieldView()
        field.title = "System Hierarchy:"
        field.delegate = self
        field.tagField = .systemHierarchy
        field.translatesAutoresizingMaskIntoConstraints = false
        return field
    }()
    
    private lazy var containerMoreFieldsView: UIView = {
        let containerView = UIView()
        containerView.translatesAutoresizingMaskIntoConstraints = false
        return containerView
    }()
    
    private lazy var arnFieldView: GpTextFieldView = {
        let field = GpTextFieldView()
        field.title = "ARN:"
        field.delegate = self
        field.tagField = .arn
        field.translatesAutoresizingMaskIntoConstraints = false
        return field
    }()
    
    private lazy var fromToTimeCreatedFieldsView: GpDoubleFieldView = {
        let fields = GpDoubleFieldView()
        fields.translatesAutoresizingMaskIntoConstraints = false
        fields.firstTitle = "deposits.list.form.from.time.created".localized()
        fields.secondTitle = "deposits.list.form.to.time.created".localized()
        
        fields.setFirstTagField(.fromTimeCreated, delegate: self)
        fields.setSecondTagField(.toTimeCreated, delegate: self)
        
        fields.firstInputPickerView = datePicker(.fromTimeCreated)
        fields.secondInputPickerView = datePicker(.toTimeCreated)
        return fields
    }()
    
    private lazy var brandStageFieldsView: GpDoubleFieldView = {
        let fields = GpDoubleFieldView()
        fields.translatesAutoresizingMaskIntoConstraints = false
        fields.firstTitle = "Brand:"
        fields.secondTitle = "Stage:"
        
        let brandData = ["NONE"] + CardBrand.allCases.map { $0.rawValue.uppercased() }
        let disputeStageData = ["NONE"] + DisputeStage.allCases.map { $0.rawValue.uppercased() }
        fields.setDropDownBoth(brandData, secondData: disputeStageData)
        
        fields.setFirstTagField(.brand, delegate: self)
        fields.setSecondTagField(.stage, delegate: self)
        return fields
    }()
    
    private lazy var moreFieldsButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.applyFlat(style: .redesignStyle, title: "reporting.more.fields.button.title".localized().uppercased())
        button.addTarget(self, action: #selector(moreFieldsPressed), for: .touchUpInside)
        return button
    }()
    
    private lazy var submitButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.applyWithImage(style: .redesignStyle, title: "reporting.disputes.view.title".localized().uppercased())
        button.addTarget(self, action: #selector(submitButtonPressed), for: .touchUpInside)
        return button
    }()
    
    override init() {
        super.init()
        separatorLineView.backgroundColor = .clear
        setUpScrollContainerViewConstraints()
        setUpSettlementsSwitchConstraints()
        setUpPageAndSizeViewConstraints()
        setUpOrderAndByViewConstraints()
        setUpStatusViewConstraints()
        setUpContainerMoreFieldViewConstraints()
        setUpSystemMidViewConstraints()
        setUpSystemHierarchyViewConstraints()
        setUpMoreFieldsButtonConstraints()
        setUpSubmitButtonConstraints()
        
        setUpSeparatorBottomLineConstraints(containerView, belowView: submitButton)
        setUpCodeResponseViewConstraints(containerView)
        setUpDataExampleCode()
        
        setUpLoadingViewConstraints()
    }
    
    private func setUpDataExampleCode() {
        codeResponseView.locationLabel = "Modules/Disputes/DisputeReport"
        codeResponseView.fileLabel = "DisputeListFormViewModel.swift"
        codeResponseView.titleResponseDataView = "DisputeListForm"
        codeResponseView.exampleCodeImage = #imageLiteral(resourceName: "reporting_dispute_id_code")
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
    
    private func setUpSettlementsSwitchConstraints() {
        containerView.addSubview(getSettlementsSwitch)
        NSLayoutConstraint.activating([
            getSettlementsSwitch.relativeTo(containerView, positioned: .top() + .width())
        ])
    }
    
    private func setUpPageAndSizeViewConstraints() {
        containerView.addSubview(pageAndPageSizeFieldsView)
        NSLayoutConstraint.activating([
            pageAndPageSizeFieldsView.relativeTo(getSettlementsSwitch, positioned: .belowWidth(spacing: DimensKeys.marginMedium))
        ])
    }
    
    private func setUpOrderAndByViewConstraints() {
        containerView.addSubview(orderAndOrderByFieldsView)
        NSLayoutConstraint.activating([
            orderAndOrderByFieldsView.relativeTo(pageAndPageSizeFieldsView, positioned: .belowWidth(spacing: DimensKeys.marginMedium))
        ])
    }
    
    private func setUpStatusViewConstraints() {
        containerView.addSubview(statusFieldView)
        NSLayoutConstraint.activating([
            statusFieldView.relativeTo(orderAndOrderByFieldsView, positioned: .belowWidth(spacing: DimensKeys.marginMedium))
        ])
    }
    
    private func setUpSystemMidViewConstraints() {
        containerView.addSubview(systemMIDFieldView)
        NSLayoutConstraint.activating([
            systemMIDFieldView.relativeTo(containerMoreFieldsView, positioned: .belowWidth(spacing: DimensKeys.marginMedium))
        ])
    }
    
    private func setUpSystemHierarchyViewConstraints() {
        containerView.addSubview(systemHierarchyFieldView)
        NSLayoutConstraint.activating([
            systemHierarchyFieldView.relativeTo(systemMIDFieldView, positioned: .belowWidth(spacing: DimensKeys.marginMedium))
        ])
    }
    
    private func setUpContainerMoreFieldViewConstraints() {
        containerView.addSubview(containerMoreFieldsView)
        NSLayoutConstraint.activating([
            containerMoreFieldsView.relativeTo(statusFieldView, positioned: .belowWidth(spacing: DimensKeys.marginMedium))
        ])
    }
    
    private func setUpMoreFieldsViewConstraints() {
        containerMoreFieldsView.addSubview(arnFieldView)
        containerMoreFieldsView.addSubview(fromToTimeCreatedFieldsView)
        containerMoreFieldsView.addSubview(brandStageFieldsView)
        
        NSLayoutConstraint.activating([
            arnFieldView.relativeTo(containerMoreFieldsView, positioned: .top() + .width()),
            fromToTimeCreatedFieldsView.relativeTo(arnFieldView, positioned: .belowWidth(spacing: DimensKeys.marginMedium)),
            brandStageFieldsView.relativeTo(fromToTimeCreatedFieldsView, positioned: .belowWidth(spacing: DimensKeys.marginMedium)),
            brandStageFieldsView.relativeTo(containerMoreFieldsView, positioned: .bottom())
        ])
    }
    
    private func removeMoreFieldsViewConstraints() {
        containerMoreFieldsView.subviews.forEach { $0.removeFromSuperview() }
    }
    
    private func setUpMoreFieldsButtonConstraints() {
        containerView.addSubview(moreFieldsButton)
        NSLayoutConstraint.activating([
            moreFieldsButton.relativeTo(systemHierarchyFieldView, positioned: .belowWidth(spacing: DimensKeys.marginMedium, margin: DimensKeys.marginMedium)),
            moreFieldsButton.constrainedBy(.constantHeight(DimensKeys.buttonSize))
        ])
    }
    
    private func setUpSubmitButtonConstraints() {
        containerView.addSubview(submitButton)
        NSLayoutConstraint.activating([
            submitButton.relativeTo(moreFieldsButton, positioned: .belowWidth(spacing: DimensKeys.marginMedium)),
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
    
    @objc func submitButtonPressed() {
        delegate?.onSubmitButtonPressed()
    }
    
    @objc func moreFieldsPressed() {
        if moreFieldsShowed {
            removeMoreFieldsViewConstraints()
        }else {
            setUpMoreFieldsViewConstraints()
        }
        moreFieldsShowed = !moreFieldsShowed
        let moreFieldsLabel = "reporting.more.fields.button.title".localized().uppercased()
        let fewerFieldsLabel = "reporting.fewer.fields.button.title".localized().uppercased()
        moreFieldsButton.setTitle(moreFieldsShowed ? fewerFieldsLabel : moreFieldsLabel, for: .normal)
    }
    
    override func setDateFromPicker(date: String, field: GpFieldsEnum) {
        switch field {
        case .fromTimeCreated:
            fromToTimeCreatedFieldsView.firstText = date
        case .toTimeCreated:
            fromToTimeCreatedFieldsView.secondText = date
        default:
            break
        }
    }
    
    func defaultValues() {
        pageAndPageSizeFieldsView.firstText = "1"
        pageAndPageSizeFieldsView.secondText = "5"
    }
    
    @objc private func onSwitchValueChanged(_ switchButton: UISwitch) {
        delegate?.setFromSettlements(switchButton.isOn)
    }
}

extension DisputeListFormView: GpTextFieldDelegate {
    
    func textChanged(value: String, type: GpFieldsEnum) {
        delegate?.fieldDataChanged(value: value, type: type)
    }
}
