import UIKit

protocol AuthenticationDataFormDelegate: AnyObject {
    func onSubmitForm(form: AuthenticationDataForm)
}

final class AuthenticationDataFormViewController: UIViewController, StoryboardInstantiable {

    static var storyboardName = "Authentications"

    private let transactionId = "AUT_Sp9zarrRYEGivHXyy1MfVuP6jIWEbe"

    @IBOutlet private weak var transactionIdLabel: UILabel!
    @IBOutlet private weak var transactionIdTextField: UITextField!
    @IBOutlet private weak var payerResponseLabel: UILabel!
    @IBOutlet private weak var payerResponseTextField: UITextField!
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
        payerResponseLabel.text = "authentication.data.form.payer.response".localized()
        payerResponseTextField.placeholder = "generic.optional".localized()
        submitButton.apply(style: .globalPayStyle, title: "generic.submit".localized())
    }

    // MARK: - Actions

    @objc private func onCancelAction() {
        dismiss(animated: true, completion: nil)
    }

    @IBAction private func onSubmitAction() {
        guard let transactionId = transactionIdTextField.text, !transactionId.isEmpty else { return }
        let form = AuthenticationDataForm(
            serverTransactionId: transactionId,
            payerAuthenticationResponse: payerResponseTextField.text
        )
        delegate?.onSubmitForm(form: form)
        dismiss(animated: true, completion: nil)
    }
}
