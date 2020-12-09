import UIKit

protocol DepositByIDFormDelegate: class {
    func onSubmitForm(_ form: DepositByIDForm)
}

final class DepositByIDFormViewController: UIViewController, StoryboardInstantiable {

    static var storyboardName = "Deposits"

    weak var delegate: DepositByIDFormDelegate?

    private let defaultDepositId = "DEP_2342423423"

    @IBOutlet private weak var submitButton: UIButton!
    @IBOutlet private weak var navigationBar: UINavigationBar!
    @IBOutlet private weak var descriptionLabel: UILabel!
    @IBOutlet private weak var inputTextView: UITextView!

    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
    }

    private func setupUI() {
        hideKeyboardWhenTappedAround()
        navigationBar.topItem?.title = "deposits.deposit.by.id.form.title".localized()
        submitButton.apply(style: .globalPayStyle, title: "deposits.deposit.by.id.form.submit".localized())
        descriptionLabel.text = "deposits.deposit.by.id.form.description".localized()
        inputTextView.text = defaultDepositId
    }

    // MARK - Actions

    @IBAction private func onCancelAction() {
        dismiss(animated: true, completion: nil)
    }

    @IBAction private func onSubmitAction() {
        guard let depositId = inputTextView.text, !depositId.isEmpty else { return }
        let form = DepositByIDForm(depositId: depositId)
        delegate?.onSubmitForm(form)
        dismiss(animated: true, completion: nil)
    }
}
