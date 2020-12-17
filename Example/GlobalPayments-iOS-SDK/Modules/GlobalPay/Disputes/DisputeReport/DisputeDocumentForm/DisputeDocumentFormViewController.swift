import UIKit

protocol DisputeDocumentFormDelegate: class {
    func onComletedForm(_ form: DisputeDocumentForm)
}

final class DisputeDocumentFormViewController: UIViewController, StoryboardInstantiable {

    static var storyboardName = "Disputes"

    private let defaultDisputeId = "DIS_SAND_abcd1235"
    private let defaultDocumentId = "DOC_MyEvidence_234234AVCDE-1"

    weak var delegate: DisputeDocumentFormDelegate?

    @IBOutlet private weak var submitButton: UIButton!
    @IBOutlet private weak var disputeIdLabel: UILabel!
    @IBOutlet private weak var disputeIdTextField: UITextField!
    @IBOutlet private weak var documentIdLabel: UILabel!
    @IBOutlet private weak var documentIdTextField: UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
    }

    private func setupUI() {
        title = "dispute.document.form.title".localized()
        navigationItem.rightBarButtonItem = NavigationItems.cancel(self, #selector(onCancelAction)).button
        submitButton.apply(style: .globalPayStyle, title: "dispute.document.form.submit".localized())

        disputeIdLabel.text = "dispute.document.form.dispute.id".localized()
        disputeIdTextField.text = defaultDisputeId
        documentIdLabel.text = "dispute.document.form.document.id".localized()
        documentIdTextField.text = defaultDocumentId
    }

    // MARK: - Actions

    @objc private func onCancelAction() {
        dismiss(animated: true, completion: nil)
    }

    @IBAction private func onSubmitAction() {
        guard let disputeId = disputeIdTextField.text, !disputeId.isEmpty,
              let documentId = documentIdTextField.text, !documentId.isEmpty else { return }

        delegate?.onComletedForm(
            DisputeDocumentForm(disputeId: disputeId, documentId: documentId)
        )
        dismiss(animated: true, completion: nil)
    }
}
