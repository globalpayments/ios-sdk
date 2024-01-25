import UIKit
import GlobalPayments_iOS_SDK

protocol DisputesOperationsFormViewDelegate: AnyObject {
    func onSubmitPressed(_ documents: [DocumentInfo])
    func onDocumentPressed()
    func fieldDataChanged(value: String, type: GpFieldsEnum)
}

class DisputesOperationsFormView: GpBaseView {
    
    private var documentButtonConstraint: NSLayoutConstraint?
    private var tableViewHeightConstraint: NSLayoutConstraint?
    private let defaultDisputeId = "DIS_SAND_abcd1235"
    
    private var documents = [DocumentInfo]()
    
    private struct DimensKeys {
        static let marginTop: CGFloat = 20
        static let marginSide: CGFloat = 20
        static let marginSmall: CGFloat = 5
        static let marginMedium: CGFloat = 15
        static let disabledButton: CGFloat = 0.3
        static let enabledButton: CGFloat = 1.0
        static let buttonSize: CGFloat = 48.0
        static let cellId: String = "DocumentCell"
    }
    
    weak var delegate: DisputesOperationsFormViewDelegate?
    
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
    
    private lazy var operationTypeFieldView: GpTextFieldView = {
        let field = GpTextFieldView()
        field.title = "disputes.operations.form.operation.type".localized()
        field.setDropDown(OperationType.allCases.map { $0.rawValue.uppercased() }, onSelectItem: operationTypeSelected, defaultValue: 0)
        field.delegate = self
        field.tagField = .operationType
        field.translatesAutoresizingMaskIntoConstraints = false
        return field
    }()
    
    private lazy var disputeIdFieldView: GpTextFieldView = {
        let field = GpTextFieldView()
        field.titleMandatory = "dispute.document.form.dispute.id".localized()
        field.tagField = .disputeId
        field.delegate = self
        field.translatesAutoresizingMaskIntoConstraints = false
        return field
    }()
    
    private lazy var idempotencyFieldView: GpTextFieldView = {
        let field = GpTextFieldView()
        field.title = "generic.idempotency.key.title".localized()
        field.delegate = self
        field.tagField = .idempotencyId
        field.translatesAutoresizingMaskIntoConstraints = false
        return field
    }()
    
    private lazy var documentsTableView: UITableView = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.register(DocumentCell.self, forCellReuseIdentifier: DimensKeys.cellId)
        tableView.separatorStyle = .none
        tableView.delegate = self
        tableView.dataSource = self
        return tableView
    }()
    
    private lazy var documentsButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.applyFlat(style: .redesignStyle, title: "document.picker.view.add.document".localized())
        button.addTarget(self, action: #selector(documentButtonPressed), for: .touchUpInside)
        return button
    }()
    
    private lazy var disputeButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.applyWithImage(style: .redesignStyle, title: "disputes.operations.initiate.opearation".localized())
        button.addTarget(self, action: #selector(submitButtonPressed), for: .touchUpInside)
        return button
    }()
    
    override init() {
        super.init()
        title = "globalpay.disputes.title".localized()
        setUpScrollContainerViewConstraints()
        setUpOperationTypeFieldConstraints()
        setUpDisputeIdFieldConstraints()
        setUpIdempotencyFieldConstraints()
        setUpDocumentsTableViewConstraints()
        setUpDocumentButtonConstraints()
        setUpStoredPaymentButtonConstraints()
        
        setUpSeparatorBottomLineConstraints(containerView, belowView: disputeButton)
        setUpCodeResponseViewConstraints(containerView)
        setUpDataExampleCode()
        
        setUpLoadingViewConstraints()
        
        documentsTableView.addObserver(self, forKeyPath: "contentSize", options: .new, context: nil)
    }
    
    private func setUpDataExampleCode() {
        codeResponseView.locationLabel = "Modules/Disputes"
        codeResponseView.fileLabel = "DisputesOperationsFormViewModel.swift"
        codeResponseView.titleResponseDataView = "DisputesOperationsInfo"
        codeResponseView.exampleCodeImage = #imageLiteral(resourceName: "disputes_code")
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
    
    private func setUpOperationTypeFieldConstraints() {
        containerView.addSubview(operationTypeFieldView)
        
        NSLayoutConstraint.activating([
            operationTypeFieldView.relativeTo(containerView, positioned: .top() + .width())
        ])
    }
    
    private func setUpDisputeIdFieldConstraints() {
        containerView.addSubview(disputeIdFieldView)
        NSLayoutConstraint.activating([
            disputeIdFieldView.relativeTo(operationTypeFieldView, positioned: .belowWidth(spacing: DimensKeys.marginMedium))
        ])
    }
    
    private func setUpIdempotencyFieldConstraints() {
        containerView.addSubview(idempotencyFieldView)
        NSLayoutConstraint.activating([
            idempotencyFieldView.relativeTo(disputeIdFieldView, positioned: .belowWidth(spacing: DimensKeys.marginMedium))
        ])
    }
    
    private func setUpDocumentsTableViewConstraints() {
        containerView.addSubview(documentsTableView)
        
        tableViewHeightConstraint = documentsTableView.heightAnchor.constraint(equalToConstant: 0)
        tableViewHeightConstraint?.isActive = true
        
        NSLayoutConstraint.activating([
            documentsTableView.relativeTo(idempotencyFieldView, positioned: .belowWidth(spacing: DimensKeys.marginMedium))
        ])
    }
    
    private func setUpDocumentButtonConstraints() {
        containerView.addSubview(documentsButton)
        documentsButton.isHidden = true
        
        documentButtonConstraint = documentsButton.heightAnchor.constraint(equalToConstant: 0)
        documentButtonConstraint?.isActive = true
        
        NSLayoutConstraint.activating([
            documentsButton.relativeTo(documentsTableView, positioned: .belowWidth(spacing: DimensKeys.marginMedium)),
        ])
    }
    
    private func setUpStoredPaymentButtonConstraints() {
        containerView.addSubview(disputeButton)
        NSLayoutConstraint.activating([
            disputeButton.relativeTo(documentsButton, positioned: .belowWidth(spacing: DimensKeys.marginMedium)),
            disputeButton.constrainedBy(.constantHeight(DimensKeys.buttonSize))
        ])
    }
    
    func defaultValues() {
        disputeIdFieldView.text = defaultDisputeId
    }
    
    @objc func documentButtonPressed() {
        delegate?.onDocumentPressed()
    }
    
    @objc func submitButtonPressed() {
        delegate?.onSubmitPressed(documents)
    }
    
    private func operationTypeSelected(_ value: String) {
        let type = OperationType(value: value.lowercased()) ?? .accept
        
        documentButtonConstraint?.constant = type == .accept ? 0.0 : DimensKeys.buttonSize
        documentsButton.isHidden = type == .accept
        
        if type == .accept {
            documents = []
            documentsTableView.reloadData()
        }
    }
    
    func enableButton(_ enable: Bool) {
        disputeButton.isEnabled = enable
        disputeButton.alpha = enable ? DimensKeys.enabledButton : DimensKeys.disabledButton
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
    
    func addDocument(_ doc: DocumentInfo) {
        documents.append(doc)
        documentsTableView.reloadData()
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "contentSize" {
            if let newvalue = change?[.newKey] {
                DispatchQueue.main.async {
                    let newsize  = newvalue as! CGSize
                    self.tableViewHeightConstraint?.constant = newsize.height
                }
            }
        }
    }
}

extension DisputesOperationsFormView: GpTextFieldDelegate {
    
    func textChanged(value: String, type: GpFieldsEnum) {
        delegate?.fieldDataChanged(value: value, type: type)
    }
}

extension DisputesOperationsFormView: UITableViewDelegate, UITableViewDataSource, DocumentDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return documents.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: DimensKeys.cellId, for: indexPath) as! DocumentCell
        let item = documents[indexPath.row]
        cell.row = indexPath.row
        if let dataImage = item.b64Content {
            cell.image = UIImage(data: dataImage)
        }
        cell.delegate = self
        cell.selectionStyle = .none
        return cell
    }
    
    func onTrashDocumentPressed(_ row: Int) {
        documents.remove(at: row)
        documentsTableView.reloadData()
    }
    
    func onDocumentTypeChanged(_ type: DocumentType, row: Int) {
        documents[row].type = type
    }
}
