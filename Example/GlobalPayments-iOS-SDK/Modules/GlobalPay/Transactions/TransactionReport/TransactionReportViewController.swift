import UIKit

final class TransactionReportViewController: UIViewController, StoryboardInstantiable {

    static var storyboardName = "Transactions"

    @IBOutlet private weak var transactionListButton: UIButton!
    @IBOutlet private weak var transactionByIdButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
    }

    func setupUI() {
        title = "transaction.report.title".localized()
        transactionListButton.apply(style: .globalPayStyle)
        transactionListButton.setTitle("transaction.report.get.list".localized(), for: .normal)
        transactionByIdButton.apply(style: .globalPayStyle)
        transactionByIdButton.setTitle("transaction.report.get.by.id".localized(), for: .normal)
    }

    // MARK: - Actions

    @IBAction func getTransactionListAction() {
        let form = TransactionListFormBuilder.build()
        navigationController?.present(form, animated: true, completion: nil)
    }

    @IBAction func getTransactionByIdAction() {
        let form = TransactionByIDFormBuilder.build()
        navigationController?.present(form, animated: true, completion: nil)
    }
}

// MARK: -

extension TransactionReportViewController {

}

// MARK: -

extension TransactionReportViewController {

}
