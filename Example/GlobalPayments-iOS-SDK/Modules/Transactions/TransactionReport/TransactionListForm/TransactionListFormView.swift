import UIKit
import GlobalPayments_iOS_SDK

protocol TransactionListFormViewDelegate: AnyObject {
    func fieldDataChanged(value: String, type: GpFieldsEnum)
    func makeRecurringEnabled(_ value: Bool)
    func onSubmitButtonPressed()
}

final class TransactionListFormView: GpBaseSingleView {
    
    weak var delegate: TransactionListFormViewDelegate?
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
        let orderByTypes = TransactionSortProperty.allCases.map { $0.rawValue.uppercased() }
        fields.setDropDownBoth(orderDirection, secondData: orderByTypes)
        fields.setFirstTagField(.order, delegate: self)
        fields.setSecondTagField(.orderBy, delegate: self)
        return fields
    }()
    
    private lazy var brandAndBrandReferenceFieldsView: GpDoubleFieldView = {
        let fields = GpDoubleFieldView()
        fields.translatesAutoresizingMaskIntoConstraints = false
        fields.firstTitle = "dispute.list.form.brand".localized()
        fields.secondTitle = "transaction.report.list.brand.reference".localized()
        
        let brandList = CardUtils.cardTypes.map { $0.key }
        fields.setDropDownBoth(brandList)
        
        fields.setFirstTagField(.brand, delegate: self)
        fields.setSecondTagField(.brandReference, delegate: self)
        return fields
    }()
    
    private lazy var authCodeFieldView: GpTextFieldView = {
        let field = GpTextFieldView()
        field.title = "Auth Code"
        field.delegate = self
        field.tagField = .authCode
        field.translatesAutoresizingMaskIntoConstraints = false
        return field
    }()
    
    private lazy var referenceFieldView: GpTextFieldView = {
        let field = GpTextFieldView()
        field.title = "Reference"
        field.delegate = self
        field.tagField = .reference
        field.translatesAutoresizingMaskIntoConstraints = false
        return field
    }()
    
    private lazy var statusFieldView: GpTextFieldView = {
        let field = GpTextFieldView()
        field.title = "Status"
        field.delegate = self
        field.tagField = .status
        field.setDropDown(TransactionStatus.allCases.map { $0.rawValue })
        field.translatesAutoresizingMaskIntoConstraints = false
        return field
    }()
    
    private lazy var numberFirst6Last4FieldsView: GpDoubleFieldView = {
        let fields = GpDoubleFieldView()
        fields.translatesAutoresizingMaskIntoConstraints = false
        fields.firstTitle = "Number First 6"
        fields.secondTitle = "Number Last 4"
        
        fields.setFirstTagField(.numberFirst6, delegate: self)
        fields.setSecondTagField(.numberLast4, delegate: self)
        return fields
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
    
    private lazy var containerMoreFieldsView: UIView = {
        let containerView = UIView()
        containerView.translatesAutoresizingMaskIntoConstraints = false
        return containerView
    }()
    
    private lazy var amountCurrencyFieldsView: GpDoubleFieldView = {
        let fields = GpDoubleFieldView()
        fields.translatesAutoresizingMaskIntoConstraints = false
        fields.firstTitle = "Amount"
        fields.secondTitle = "Currency"
        
        fields.setFirstTagField(.amount, delegate: self)
        fields.setSecondTagField(.currency, delegate: self)
        return fields
    }()
    
    private lazy var idFieldView: GpTextFieldView = {
        let field = GpTextFieldView()
        field.title = "ID"
        field.delegate = self
        field.tagField = .transactionId
        field.translatesAutoresizingMaskIntoConstraints = false
        return field
    }()
    
    private lazy var typeChannelFieldsView: GpDoubleFieldView = {
        let fields = GpDoubleFieldView()
        fields.translatesAutoresizingMaskIntoConstraints = false
        fields.firstTitle = "Type"
        fields.secondTitle = "Channel"
        
        let paymentType = PaymentType.allCases.map { $0.rawValue }
        let channels = Channel.allCases.map { $0.rawValue }
        fields.setDropDownBoth(paymentType, secondData: channels)
        
        fields.setFirstTagField(.type, delegate: self)
        fields.setSecondTagField(.channel, delegate: self)
        return fields
    }()
    
    private lazy var tokenFirst6Last4FieldsView: GpDoubleFieldView = {
        let fields = GpDoubleFieldView()
        fields.translatesAutoresizingMaskIntoConstraints = false
        fields.firstTitle = "Token First 6"
        fields.secondTitle = "Token Last 4"
        
        fields.setFirstTagField(.tokenFirst6, delegate: self)
        fields.setSecondTagField(.tokenLast4, delegate: self)
        return fields
    }()
    
    private lazy var accountNameFieldView: GpTextFieldView = {
        let field = GpTextFieldView()
        field.title = "Account Name"
        field.delegate = self
        field.tagField = .accountHolderName
        field.translatesAutoresizingMaskIntoConstraints = false
        return field
    }()
    
    private lazy var countryFieldView: GpTextFieldView = {
        let field = GpTextFieldView()
        field.title = "Country"
        field.delegate = self
        field.tagField = .country
        field.translatesAutoresizingMaskIntoConstraints = false
        return field
    }()
    
    private lazy var batchIdFieldView: GpTextFieldView = {
        let field = GpTextFieldView()
        field.title = "Batch ID:"
        field.delegate = self
        field.tagField = .batchId
        field.translatesAutoresizingMaskIntoConstraints = false
        return field
    }()
    
    private lazy var entryModeFieldView: GpTextFieldView = {
        let field = GpTextFieldView()
        field.title = "Entry Mode:"
        field.delegate = self
        field.tagField = .entryMode
        field.setDropDown(PaymentEntryMode.allCases.map { $0.rawValue })
        field.translatesAutoresizingMaskIntoConstraints = false
        return field
    }()
    
    private lazy var nameFieldView: GpTextFieldView = {
        let field = GpTextFieldView()
        field.title = "Name:"
        field.delegate = self
        field.tagField = .name
        field.translatesAutoresizingMaskIntoConstraints = false
        return field
    }()
    
    private lazy var moreFieldsButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.applyFlat(style: .redesignStyle, title: "MORE FIELDS")
        button.addTarget(self, action: #selector(moreFieldsPressed), for: .touchUpInside)
        return button
    }()
    
    private lazy var submitButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.applyWithImage(style: .redesignStyle, title: "GET TRANSACTIONS")
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
        setUpBrandAndReferenceViewConstraints()
        setUpAuthCodeViewConstraints()
        setUpReferenceViewConstraints()
        setUpStatusViewConstraints()
        setUpNumberFirstLastViewConstraints()
        setUpFromToTimeCreatedViewConstraints()
        setUpContainerMoreFieldViewConstraints()
        setUpMoreFieldsButtonConstraints()
        setUpSubmitButtonConstraints()
        
        setUpSeparatorBottomLineConstraints(containerView, belowView: submitButton)
        setUpCodeResponseViewConstraints(containerView)
        setUpDataExampleCode()
        
        setUpLoadingViewConstraints()
    }
    
    private func setUpDataExampleCode() {
        codeResponseView.locationLabel = "Modules/Transactions/TransactionReport"
        codeResponseView.fileLabel = "TransactionListFormViewModel.swift"
        codeResponseView.titleResponseDataView = "TransactionsList"
        codeResponseView.exampleCodeImage = #imageLiteral(resourceName: "reporting_transaction_list_code")
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
    
    private func setUpBrandAndReferenceViewConstraints() {
        containerView.addSubview(brandAndBrandReferenceFieldsView)
        NSLayoutConstraint.activating([
            brandAndBrandReferenceFieldsView.relativeTo(orderAndOrderByFieldsView, positioned: .belowWidth(spacing: DimensKeys.marginMedium))
        ])
    }
    
    private func setUpAuthCodeViewConstraints() {
        containerView.addSubview(authCodeFieldView)
        NSLayoutConstraint.activating([
            authCodeFieldView.relativeTo(brandAndBrandReferenceFieldsView, positioned: .belowWidth(spacing: DimensKeys.marginMedium))
        ])
    }
    
    private func setUpReferenceViewConstraints() {
        containerView.addSubview(referenceFieldView)
        NSLayoutConstraint.activating([
            referenceFieldView.relativeTo(authCodeFieldView, positioned: .belowWidth(spacing: DimensKeys.marginMedium))
        ])
    }
    
    private func setUpStatusViewConstraints() {
        containerView.addSubview(statusFieldView)
        NSLayoutConstraint.activating([
            statusFieldView.relativeTo(referenceFieldView, positioned: .belowWidth(spacing: DimensKeys.marginMedium))
        ])
    }
    
    private func setUpNumberFirstLastViewConstraints() {
        containerView.addSubview(numberFirst6Last4FieldsView)
        NSLayoutConstraint.activating([
            numberFirst6Last4FieldsView.relativeTo(statusFieldView, positioned: .belowWidth(spacing: DimensKeys.marginMedium))
        ])
    }
    
    private func setUpFromToTimeCreatedViewConstraints() {
        containerView.addSubview(fromToTimeCreatedFieldsView)
        NSLayoutConstraint.activating([
            fromToTimeCreatedFieldsView.relativeTo(numberFirst6Last4FieldsView, positioned: .belowWidth(spacing: DimensKeys.marginMedium))
        ])
    }
    
    private func setUpContainerMoreFieldViewConstraints() {
        containerView.addSubview(containerMoreFieldsView)
        NSLayoutConstraint.activating([
            containerMoreFieldsView.relativeTo(fromToTimeCreatedFieldsView, positioned: .belowWidth(spacing: DimensKeys.marginMedium))
        ])
    }
    
    private func setUpMoreFieldsViewConstraints() {
        containerMoreFieldsView.addSubview(amountCurrencyFieldsView)
        containerMoreFieldsView.addSubview(idFieldView)
        containerMoreFieldsView.addSubview(typeChannelFieldsView)
        containerMoreFieldsView.addSubview(tokenFirst6Last4FieldsView)
        containerMoreFieldsView.addSubview(accountNameFieldView)
        containerMoreFieldsView.addSubview(countryFieldView)
        containerMoreFieldsView.addSubview(batchIdFieldView)
        containerMoreFieldsView.addSubview(entryModeFieldView)
        containerMoreFieldsView.addSubview(nameFieldView)
        
        NSLayoutConstraint.activating([
            amountCurrencyFieldsView.relativeTo(containerMoreFieldsView, positioned: .top() + .width()),
            idFieldView.relativeTo(amountCurrencyFieldsView, positioned: .belowWidth(spacing: DimensKeys.marginMedium)),
            typeChannelFieldsView.relativeTo(idFieldView, positioned: .belowWidth(spacing: DimensKeys.marginMedium)),
            tokenFirst6Last4FieldsView.relativeTo(typeChannelFieldsView, positioned: .belowWidth(spacing: DimensKeys.marginMedium)),
            accountNameFieldView.relativeTo(tokenFirst6Last4FieldsView, positioned: .belowWidth(spacing: DimensKeys.marginMedium)),
            countryFieldView.relativeTo(accountNameFieldView, positioned: .belowWidth(spacing: DimensKeys.marginMedium)),
            batchIdFieldView.relativeTo(countryFieldView, positioned: .belowWidth(spacing: DimensKeys.marginMedium)),
            entryModeFieldView.relativeTo(batchIdFieldView, positioned: .belowWidth(spacing: DimensKeys.marginMedium)),
            nameFieldView.relativeTo(entryModeFieldView, positioned: .belowWidth(spacing: DimensKeys.marginMedium)),
            nameFieldView.relativeTo(containerMoreFieldsView, positioned: .bottom())
        ])
    }
    
    private func removeMoreFieldsViewConstraints() {
        containerMoreFieldsView.subviews.forEach { $0.removeFromSuperview() }
    }
    
    private func setUpMoreFieldsButtonConstraints() {
        containerView.addSubview(moreFieldsButton)
        NSLayoutConstraint.activating([
            moreFieldsButton.relativeTo(containerMoreFieldsView, positioned: .belowWidth(spacing: DimensKeys.marginMedium, margin: DimensKeys.marginMedium)),
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
    
    @objc private func onSwitchValueChanged(_ switchButton: UISwitch) {
        delegate?.makeRecurringEnabled(switchButton.isOn)
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
        moreFieldsButton.setTitle(moreFieldsShowed ? "FEWER FIELDS" : "MORE FIELDS", for: .normal)
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

extension TransactionListFormView: GpTextFieldDelegate {
    
    func textChanged(value: String, type: GpFieldsEnum) {
        delegate?.fieldDataChanged(value: value, type: type)
    }
}


