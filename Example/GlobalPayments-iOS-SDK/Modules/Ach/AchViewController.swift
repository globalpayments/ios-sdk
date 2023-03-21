import UIKit
import GlobalPayments_iOS_SDK

final class AchViewController: UIViewController, StoryboardInstantiable {

    static var storyboardName = "Ach"

    var viewModel: AchViewInput!

    @IBOutlet private weak var chargeButton: UIButton!
    @IBOutlet private weak var refundButton: UIButton!
    @IBOutlet private weak var supportView: UIView!
    @IBOutlet private weak var activityIndicator: UIActivityIndicatorView!

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }

    private func setupUI() {
        title = "ach.title".localized()
        hideKeyboardWhenTappedAround()

        chargeButton.apply(style: .globalPayStyle, title: "ach.charge".localized())
        refundButton.apply(style: .globalPayStyle, title: "ach.refund".localized())

        activityIndicator.stopAnimating()
    }

    // MARK: - Actions

    @IBAction func onChargeAction(_ sender: Any) {
        let form = AchChargeFormBuilder.build(with: self, by: .charge)
        navigationController?.present(form, animated: true, completion: nil)
    }

    @IBAction func onRefundAction(_ sender: Any) {
        let form = AchChargeFormBuilder.build(with: self, by: .refund)
        navigationController?.present(form, animated: true, completion: nil)
    }
}

// MARK: - TransactionOperationsFormDelegate

extension AchViewController: AchChargeFormDelegate {

    func onSubmitForm(form: AchChargeForm, path: AchPath) {
        activityIndicator.startAnimating()
        viewModel.doAchTransaction(from: form, path: path)
        supportView.clearSubviews()
    }
}

// MARK: - AchViewOutput

extension AchViewController: AchViewOutput {

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
