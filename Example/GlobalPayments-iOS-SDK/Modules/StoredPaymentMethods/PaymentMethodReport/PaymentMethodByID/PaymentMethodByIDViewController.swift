import UIKit

protocol PaymentMethodByIDDelegate: class {
    func onSubmitForm(paymentMethodId: String)
}

final class PaymentMethodByIDViewController: UIViewController, StoryboardInstantiable {

    static var storyboardName = "PaymentMethods"

    private let defaultPaymentMethodId = "PMT_98e6cbbb-8faf-4134-bfa1-f2cf3a72872f"

    weak var delegate: PaymentMethodByIDDelegate?

    @IBOutlet private weak var submitButton: UIButton!
    @IBOutlet private weak var descriptionLabel: UILabel!
    @IBOutlet private weak var inputTextView: UITextView!

    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
    }

    private func setupUI() {
        hideKeyboardWhenTappedAround()
        title = "payment.methods.report.id.title".localized()
        navigationItem.rightBarButtonItem = NavigationItems.cancel(self, #selector(onCancelAction)).button
        submitButton.apply(style: .globalPayStyle, title: "payment.methods.report.id.submit".localized())
        descriptionLabel.text = "payment.methods.report.id.payment.method".localized()
        inputTextView.text = defaultPaymentMethodId
    }

    // MARK: - Actoins

    @IBAction private func onCancelAction() {
        dismiss(animated: true, completion: nil)
    }

    @IBAction private func onSubmitAction() {
        guard let id = inputTextView.text else { return }
        delegate?.onSubmitForm(paymentMethodId: id)
        dismiss(animated: true, completion: nil)
    }
}
