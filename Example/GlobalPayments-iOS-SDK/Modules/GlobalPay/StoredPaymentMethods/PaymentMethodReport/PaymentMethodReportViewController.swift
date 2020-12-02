import UIKit
import GlobalPayments_iOS_SDK

final class PaymentMethodReportViewController: UIViewController, StoryboardInstantiable {

    static var storyboardName = "PaymentMethods"

    var viewModel: PaymentMethodReportInput!

    @IBOutlet private weak var paymentsListButton: UIButton!
    @IBOutlet private weak var paymentByIdButton: UIButton!
    @IBOutlet private weak var supportView: UIView!
    @IBOutlet private weak var activityIndicator: UIActivityIndicatorView!

    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
    }

    private func setupUI() {
        title = "payment.methods.report.title".localized()
        paymentsListButton.apply(style: .globalPayStyle)
        paymentsListButton.setTitle("payment.methods.report.list".localized(), for: .normal)
        paymentByIdButton.apply(style: .globalPayStyle)
        paymentByIdButton.setTitle("payment.methods.report.id".localized(), for: .normal)
        activityIndicator.stopAnimating()
    }

    // MARK: - Actions

    @IBAction private func getPaymentsListAction() {
        showAlert(message: "payment.methods.not.implemented.title".localized())
    }

    @IBAction private func getPaymentByIdAction() {
        let form = PaymentMethodByIDBuilder.build(with: self)
        present(form, animated: true, completion: nil)
    }
}

// MARK: - PaymentMethodReportOutput

extension PaymentMethodReportViewController: PaymentMethodReportOutput {

    func showError(error: Error?) {
        activityIndicator.stopAnimating()
        let errorView = ErrorView.instantiateFromNib()
        errorView.display(error)
        supportView.addSubview(errorView)
        errorView.bindFrameToSuperviewBounds()
    }

    func showTransaction(_ transaction: Transaction) {
        activityIndicator.stopAnimating()
        let transactionView = PaymentMethodView.instantiateFromNib()
        transactionView.display(transaction)
        supportView.addSubview(transactionView)
        transactionView.bindFrameToSuperviewBounds()
    }
}

// MARK: - PaymentMethodByIDDelegate

extension PaymentMethodReportViewController: PaymentMethodByIDDelegate {

    func onSubmitForm(paymentMethodId: String) {
        activityIndicator.startAnimating()
        viewModel.getPaymentMethodById(paymentMethodId)
        supportView.clearSubviews()
    }
}
