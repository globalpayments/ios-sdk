import UIKit
import GlobalPayments_iOS_SDK

final class TransactionOperationsViewController: UIViewController, StoryboardInstantiable {

    static var storyboardName = "Transactions"

    var viewModel: TransactionOperationsInput!

    @IBOutlet private weak var submitButton: UIButton!
    @IBOutlet private weak var supportView: UIView!
    @IBOutlet private weak var activityIndicator: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
    }

    private func setupUI() {
        title = "transactoin.operations.title".localized()
        submitButton.apply(style: .globalPayStyle)
        submitButton.setTitle("transactoin.operations.create.transaction".localized(), for: .normal)
        activityIndicator.stopAnimating()
    }

    // MARK: - Actions

    @IBAction func onSubmitButtonAction() {
        let form = TransactionOperationsFormBuilder.build(with: self)
        navigationController?.present(form, animated: true, completion: nil)
    }
}

// MARK: - TransactionOperationsFormDelegate

extension TransactionOperationsViewController: TransactionOperationsFormDelegate {

    func onSubmitForm(form: TransactionOperationsForm) {
        activityIndicator.startAnimating()
        viewModel.getTransaction(from: form)
        supportView.clearSubviews()
    }
}

// MARK: - TransactionOperationsOutput

extension TransactionOperationsViewController: TransactionOperationsOutput {

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
