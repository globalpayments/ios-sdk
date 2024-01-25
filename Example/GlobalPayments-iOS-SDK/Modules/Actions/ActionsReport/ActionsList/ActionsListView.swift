import UIKit
import GlobalPayments_iOS_SDK

protocol ActionsListViewDelegate: AnyObject {
    func fieldDataChanged(value: String, type: GpFieldsEnum)
    func onSubmitButtonPressed()
}

final class ActionsListView: GpBaseSingleView {
    
    weak var delegate: ActionsListViewDelegate?
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
        let orderByTypes = ActionSortProperty.allCases.map { $0.rawValue.uppercased() }
        fields.setDropDownBoth(orderDirection, secondData: orderByTypes)
        fields.setFirstTagField(.order, delegate: self)
        fields.setSecondTagField(.orderBy, delegate: self)
        return fields
    }()
    
    private lazy var appNameFieldView: GpTextFieldView = {
        let field = GpTextFieldView()
        field.title = "App Name:"
        field.delegate = self
        field.tagField = .appName
        field.translatesAutoresizingMaskIntoConstraints = false
        return field
    }()
    
    private lazy var versionFieldView: GpTextFieldView = {
        let field = GpTextFieldView()
        field.title = "Version:"
        field.delegate = self
        field.tagField = .version
        field.translatesAutoresizingMaskIntoConstraints = false
        return field
    }()
    
    private lazy var containerMoreFieldsView: UIView = {
        let containerView = UIView()
        containerView.translatesAutoresizingMaskIntoConstraints = false
        return containerView
    }()
    
    private lazy var idFieldView: GpTextFieldView = {
        let field = GpTextFieldView()
        field.title = "ID:"
        field.delegate = self
        field.tagField = .id
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
    
    private lazy var typeResourceFieldsView: GpDoubleFieldView = {
        let fields = GpDoubleFieldView()
        fields.translatesAutoresizingMaskIntoConstraints = false
        fields.firstTitle = "Type:"
        fields.secondTitle = "Resource:"
        
        fields.setFirstTagField(.type, delegate: self)
        fields.setSecondTagField(.resource, delegate: self)
        return fields
    }()
    
    private lazy var resourceStatusAndIDFieldsView: GpDoubleFieldView = {
        let fields = GpDoubleFieldView()
        fields.translatesAutoresizingMaskIntoConstraints = false
        fields.firstTitle = "Resource Status:"
        fields.secondTitle = "Resource Id:"
        
        fields.setFirstTagField(.resourceStatus, delegate: self)
        fields.setSecondTagField(.resourceId, delegate: self)
        return fields
    }()
    
    private lazy var merchantNameAccountNameFieldsView: GpDoubleFieldView = {
        let fields = GpDoubleFieldView()
        fields.translatesAutoresizingMaskIntoConstraints = false
        fields.firstTitle = "Merchant Name:"
        fields.secondTitle = "Account Name:"
        
        fields.setFirstTagField(.merchantName, delegate: self)
        fields.setSecondTagField(.accountName, delegate: self)
        return fields
    }()
    
    private lazy var responseCodeHttpCodeFieldsView: GpDoubleFieldView = {
        let fields = GpDoubleFieldView()
        fields.translatesAutoresizingMaskIntoConstraints = false
        fields.firstTitle = "Response Code:"
        fields.secondTitle = "Http Response Code:"
        
        fields.setFirstTagField(.responseCode, delegate: self)
        fields.setSecondTagField(.httpResponseCode, delegate: self)
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
        button.applyWithImage(style: .redesignStyle, title: "reporting.payment.methods.button.title".localized().uppercased())
        button.addTarget(self, action: #selector(submitButtonPressed), for: .touchUpInside)
        return button
    }()
    
    override init() {
        super.init()
        separatorLineView.backgroundColor = .clear
        setUpScrollContainerViewConstraints()
        setUpPageAndSizeViewConstraints()
        setUpOrderAndByViewConstraints()
        setUpContainerMoreFieldViewConstraints()
        setUpAppNameViewConstraints()
        setUpVersionViewConstraints()
        setUpMoreFieldsButtonConstraints()
        setUpSubmitButtonConstraints()
        
        setUpSeparatorBottomLineConstraints(containerView, belowView: submitButton)
        setUpCodeResponseViewConstraints(containerView)
        setUpDataExampleCode()
        
        setUpLoadingViewConstraints()
    }
    
    private func setUpDataExampleCode() {
        codeResponseView.locationLabel = "Modules/Actions/ActionsReport"
        codeResponseView.fileLabel = "ActionsListViewModel.swift"
        codeResponseView.titleResponseDataView = "ActionsList"
        codeResponseView.exampleCodeImage = #imageLiteral(resourceName: "reporting_actions_list_code")
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
    
    private func setUpPageAndSizeViewConstraints() {
        containerView.addSubview(pageAndPageSizeFieldsView)
        NSLayoutConstraint.activating([
            pageAndPageSizeFieldsView.relativeTo(containerView, positioned: .top() + .width())
        ])
    }
    
    private func setUpOrderAndByViewConstraints() {
        containerView.addSubview(orderAndOrderByFieldsView)
        NSLayoutConstraint.activating([
            orderAndOrderByFieldsView.relativeTo(pageAndPageSizeFieldsView, positioned: .belowWidth(spacing: DimensKeys.marginMedium))
        ])
    }
    
    private func setUpContainerMoreFieldViewConstraints() {
        containerView.addSubview(containerMoreFieldsView)
        NSLayoutConstraint.activating([
            containerMoreFieldsView.relativeTo(orderAndOrderByFieldsView, positioned: .belowWidth(spacing: DimensKeys.marginMedium))
        ])
    }
    
    private func setUpAppNameViewConstraints() {
        containerView.addSubview(appNameFieldView)
        NSLayoutConstraint.activating([
            appNameFieldView.relativeTo(containerMoreFieldsView, positioned: .belowWidth(spacing: DimensKeys.marginMedium))
        ])
    }
    
    private func setUpVersionViewConstraints() {
        containerView.addSubview(versionFieldView)
        NSLayoutConstraint.activating([
            versionFieldView.relativeTo(appNameFieldView, positioned: .belowWidth(spacing: DimensKeys.marginMedium))
        ])
    }
    
    private func setUpMoreFieldsViewConstraints() {
        containerMoreFieldsView.addSubview(idFieldView)
        containerMoreFieldsView.addSubview(fromToTimeCreatedFieldsView)
        containerMoreFieldsView.addSubview(typeResourceFieldsView)
        containerMoreFieldsView.addSubview(resourceStatusAndIDFieldsView)
        containerMoreFieldsView.addSubview(merchantNameAccountNameFieldsView)
        containerMoreFieldsView.addSubview(responseCodeHttpCodeFieldsView)
        
        NSLayoutConstraint.activating([
            idFieldView.relativeTo(containerMoreFieldsView, positioned: .top() + .width()),
            fromToTimeCreatedFieldsView.relativeTo(idFieldView, positioned: .belowWidth(spacing: DimensKeys.marginMedium)),
            typeResourceFieldsView.relativeTo(fromToTimeCreatedFieldsView, positioned: .belowWidth(spacing: DimensKeys.marginMedium)),
            resourceStatusAndIDFieldsView.relativeTo(typeResourceFieldsView, positioned: .belowWidth(spacing: DimensKeys.marginMedium)),
            merchantNameAccountNameFieldsView.relativeTo(resourceStatusAndIDFieldsView, positioned: .belowWidth(spacing: DimensKeys.marginMedium)),
            responseCodeHttpCodeFieldsView.relativeTo(merchantNameAccountNameFieldsView, positioned: .belowWidth(spacing: DimensKeys.marginMedium)),
            responseCodeHttpCodeFieldsView.relativeTo(containerMoreFieldsView, positioned: .bottom()),
        ])
    }
    
    private func removeMoreFieldsViewConstraints() {
        containerMoreFieldsView.subviews.forEach { $0.removeFromSuperview() }
    }
    
    private func setUpMoreFieldsButtonConstraints() {
        containerView.addSubview(moreFieldsButton)
        NSLayoutConstraint.activating([
            moreFieldsButton.relativeTo(versionFieldView, positioned: .belowWidth(spacing: DimensKeys.marginMedium, margin: DimensKeys.marginMedium)),
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
}

extension ActionsListView: GpTextFieldDelegate {
    
    func textChanged(value: String, type: GpFieldsEnum) {
        delegate?.fieldDataChanged(value: value, type: type)
    }
}
