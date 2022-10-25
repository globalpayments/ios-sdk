import UIKit

protocol AuthenticationDataFormDelegate: AnyObject {
    func onSubmitForm(form: AuthenticationDataForm)
}

final class AuthenticationDataFormViewController: UIViewController, StoryboardInstantiable {

    static var storyboardName = "Authentications"

    private let transactionId = "AUT_Sp9zarrRYEGivHXyy1MfVuP6jIWEbe"

    @IBOutlet private weak var transactionIdLabel: UILabel!
    @IBOutlet private weak var transactionIdTextField: UITextField!
    @IBOutlet private weak var submitButton: UIButton!

    weak var delegate: AuthenticationDataFormDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
    }

    private func setupUI() {
        title = "authentication.data.form.title".localized()
        navigationItem.rightBarButtonItem = NavigationItems.cancel(self, #selector(onCancelAction)).button

        transactionIdLabel.text = "authentication.data.form.transaction.id".localized()
        transactionIdTextField.text = transactionId
        submitButton.apply(style: .globalPayStyle, title: "generic.submit".localized())
    }

    // MARK: - Actions

    @objc private func onCancelAction() {
        dismiss(animated: true, completion: nil)
    }

    @IBAction private func onSubmitAction() {
        guard let transactionId = transactionIdTextField.text, !transactionId.isEmpty else { return }
        let form = AuthenticationDataForm(
            serverTransactionId: transactionId
        )
        delegate?.onSubmitForm(form: form)
        dismiss(animated: true, completion: nil)
    }
}
