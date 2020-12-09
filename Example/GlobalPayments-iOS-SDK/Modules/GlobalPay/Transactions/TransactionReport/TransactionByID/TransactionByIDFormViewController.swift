import UIKit

protocol TransactionByIDFormDelegate: class {
    func onComletedForm(transactionID: String)
}

final class TransactionByIDFormViewController: UIViewController, StoryboardInstantiable {

    static var storyboardName = "Transactions"
    private let transactionIdExample = "TRN_7g3faeVD43hkwAQ44k5vgTzl4tb1Ep"

    weak var delegate: TransactionByIDFormDelegate?

    @IBOutlet private weak var navigationBar: UINavigationBar!
    @IBOutlet private weak var submitButton: UIButton!
    @IBOutlet private weak var transactionIDLabel: UILabel!
    @IBOutlet private weak var transactionIDTextView: UITextView!

    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
    }

    private func setupUI() {
        hideKeyboardWhenTappedAround()
        navigationBar.topItem?.title = "transaction.report.by.id.form.title".localized()
        submitButton.apply(style: .globalPayStyle, title: "transaction.report.by.id.submit".localized())
        transactionIDLabel.text = "transaction.report.by.id.form".localized()
        transactionIDTextView.text = transactionIdExample
    }

    // MARK: - Actions

    @IBAction private func onCloseAction() {
        dismiss(animated: true, completion: nil)
    }

    @IBAction private func onSubmitAction() {
        guard let transactionId = transactionIDTextView.text, !transactionId.isEmpty else { return }
        delegate?.onComletedForm(transactionID: transactionId)
        dismiss(animated: true, completion: nil)
    }
}
