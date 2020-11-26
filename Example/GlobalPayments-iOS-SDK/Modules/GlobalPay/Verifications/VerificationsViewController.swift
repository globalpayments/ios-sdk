import UIKit
import GlobalPayments_iOS_SDK

final class VerificationsViewController: UIViewController, StoryboardInstantiable {

    static var storyboardName = "Verifications"

    var viewModel: VerificationsViewModelInput!

    @IBOutlet private weak var initiatePaymentButton: UIButton!
    @IBOutlet private weak var supportView: UIView!
    @IBOutlet private weak var activityIndicator: UIActivityIndicatorView!

    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
    }

    private func setupUI() {
        title = "verifications.title".localized()
        initiatePaymentButton.setTitle("verifications.initiate.verification".localized(), for: .normal)
        initiatePaymentButton.apply(style: .globalPayStyle)
        activityIndicator.stopAnimating()
    }

    // MARK: - Actions

    @IBAction private func onInitiatePaymentAction() {
        let form = VerificationsFormBuilder.build(with: self)
        present(form, animated: true, completion: nil)
    }
}

// MARK: - VerificationsFormDelegate

extension VerificationsViewController: VerificationsFormDelegate {

    func onSubmitForm(_ form: VerificationsForm) {
        activityIndicator.startAnimating()
        viewModel.verifyTransaction(from: form)
        supportView.clearSubviews()
    }
}

// MARK: - VerificationsViewModelOutput

extension VerificationsViewController: VerificationsViewModelOutput {

    func showErrorView(error: Error?) {
        activityIndicator.stopAnimating()
        let errorView = ErrorView.instantiateFromNib()
        errorView.display(error)
        supportView.addSubview(errorView)
        errorView.bindFrameToSuperviewBounds()
    }

    func showTransaction(_ transaction: Transaction) {
        activityIndicator.stopAnimating()
        let transactionView = TransactionView.instantiateFromNib()
        transactionView.display(transaction)
        supportView.addSubview(transactionView)
        transactionView.bindFrameToSuperviewBounds()
    }
}
