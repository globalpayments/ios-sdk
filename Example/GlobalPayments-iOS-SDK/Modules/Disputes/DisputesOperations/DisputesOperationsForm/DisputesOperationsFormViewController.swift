import UIKit
import GlobalPayments_iOS_SDK

protocol DisputesOperationsFormDelegate: class {
    func onAcceptDispute(_ disputeId: String)
    func onChallengeDispute(_ disputeId: String, documents: [DocumentInfo])
}

final class DisputesOperationsFormViewController: UIViewController, StoryboardInstantiable {

    static var storyboardName = "Disputes"

    private let defaultDisputeId = "DIS_SAND_abcd1235"

    @IBOutlet private weak var submitButton: UIButton!
    @IBOutlet private weak var operationTypeLabel: UILabel!
    @IBOutlet private weak var operationTypeTextField: UITextField!
    @IBOutlet private weak var disputeIdLabel: UILabel!
    @IBOutlet private weak var disputeIdTextField: UITextField!
    @IBOutlet private weak var tableView: UITableView!
    @IBOutlet private weak var detailsStackView: UIStackView!

    lazy var documentPicker: DocumentPickerView = {
        let documentPicker = DocumentPickerView.instantiateFromNib()
        documentPicker.setInitialState()
        documentPicker.isHidden = true
        documentPicker.delegate = self
        return documentPicker
    }()
    
    weak var delegate: DisputesOperationsFormDelegate?

    private var documents = [DocumentInfo]()

    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
    }

    private func setupUI() {
        title = "disputes.operations.form.title".localized()
        navigationItem.rightBarButtonItem = NavigationItems.cancel(self, #selector(onCancelAction)).button
        submitButton.apply(style: .globalPayStyle, title: "disputes.operations.form.submit".localized())
        operationTypeLabel.text = "disputes.operations.form.operation.type".localized()
        operationTypeTextField.loadDropDownData(OperationType.allCases.map { $0.rawValue.uppercased() }, onSelectItem: onChangeOperation)
        disputeIdLabel.text = "disputes.operations.form.dispute.id".localized()
        disputeIdTextField.text = defaultDisputeId
        detailsStackView.addArrangedSubview(documentPicker)

        setupTable()
    }

    private func setupTable() {
        tableView.dataSource = self
        tableView.register(UINib(nibName: DisputeDocumentTableViewCell.identifier, bundle: nil),
                           forCellReuseIdentifier: DisputeDocumentTableViewCell.identifier)
        tableView.tableFooterView = UIView()
    }

    // MARK: - Actions

    private func onChangeOperation(_ operation: String) {
        guard let operation = OperationType(rawValue: operation.lowercased()) else { return }
        UIView.animate(withDuration: 0.5, delay: 0.0, usingSpringWithDamping: 0.9, initialSpringVelocity: 1, options: [],
                       animations: {
                        switch operation {
                        case .accept:
                            self.tableView.alpha = 0
                            self.documentPicker.isHidden = true
                        case .challenge:
                            self.tableView.alpha = 1
                            self.documentPicker.isHidden = false
                        }
                       }
        )
    }

    @objc private func onCancelAction() {
        dismiss(animated: true, completion: nil)
    }

    @IBAction private func onSubmitAction() {
        guard let operation = OperationType(value: operationTypeTextField.text?.lowercased()) else { return }
        switch operation {
        case .accept:
            guard let disputeId = disputeIdTextField.text, !disputeId.isEmpty else { return }
            delegate?.onAcceptDispute(disputeId)
            dismiss(animated: true, completion: nil)
        case .challenge:
            guard let disputeId = disputeIdTextField.text, !disputeId.isEmpty else { return }
            guard !documents.isEmpty else { return }
            delegate?.onChallengeDispute(disputeId, documents: documents)
            dismiss(animated: true, completion: nil)
        }
    }
}

// MARK: - DocumentPickerViewDelegate

extension DisputesOperationsFormViewController: DocumentPickerViewDelegate {

    func imageNotSelected() {
        showAlert(message: "disputes.operations.form.image.not.selected".localized())
    }

    func onSelectDocument(_ document: DocumentInfo) {
        documents.append(document)
        tableView.reloadData()
        documentPicker.setInitialState()
    }
}

// MARK: - UITableViewDataSource

extension DisputesOperationsFormViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        documents.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: DisputeDocumentTableViewCell.identifier, for: indexPath) as! DisputeDocumentTableViewCell
        cell.setup(viewModel: documents[indexPath.row])
        return cell
    }

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            documents.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
}
