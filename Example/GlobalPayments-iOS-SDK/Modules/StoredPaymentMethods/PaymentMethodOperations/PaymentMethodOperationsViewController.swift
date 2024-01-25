import UIKit

final class PaymentMethodOperationsViewController: UIViewController, StoryboardInstantiable {

    static var storyboardName = "PaymentMethods"

    var viewModel: PaymentMethodOperationsInput!

    @IBOutlet private weak var initiatePaymentButton: UIButton!
    @IBOutlet private weak var supportView: UIView!
    @IBOutlet private weak var activityIndicator: UIActivityIndicatorView!

    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
    }

    private func setupUI() {
        title = "payment.method.operations.title".localized()
        initiatePaymentButton.apply(
            style: .globalPayStyle,
            title: "payment.method.operations.payment.operation".localized()
        )
        activityIndicator.stopAnimating()
    }

    // MARK: - Actions

    @IBAction private func onInitiatePaymentAction() {
        let form = PaymentOperationFormBuilder.build()
        present(form, animated: true, completion: nil)
    }
}

// MARK: - PaymentMethodOperationsOutput

extension PaymentMethodOperationsViewController: PaymentMethodOperationsOutput {

    func showError(error: Error?) {
        activityIndicator.stopAnimating()
        let errorView = ErrorView.instantiateFromNib()
        errorView.display(error)
        supportView.addSubview(errorView)
        errorView.bindFrameToSuperviewBounds()
    }

    func showViewModels(models: [PaymentMethodResultModel]) {
        activityIndicator.stopAnimating()
        let paymentMethodResultView = PaymentMethodResultView.instantiateFromNib()
        paymentMethodResultView.display(models)
        supportView.addSubview(paymentMethodResultView)
        paymentMethodResultView.bindFrameToSuperviewBounds()
    }
}
