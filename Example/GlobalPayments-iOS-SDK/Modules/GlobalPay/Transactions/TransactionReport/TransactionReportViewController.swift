import UIKit

final class TransactionReportViewController: UIViewController, StoryboardInstantiable {

    static var storyboardName = "Transactions"

    var viewModel: TransactionReportViewInput!

    @IBOutlet private weak var transactionListButton: UIButton!
    @IBOutlet private weak var transactionByIdButton: UIButton!
    @IBOutlet private weak var tableView: UITableView!
    @IBOutlet private weak var activityIndicator: UIActivityIndicatorView!

    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
    }

    private func setupUI() {
        setupTable()
        title = "transaction.report.title".localized()
        transactionListButton.apply(style: .globalPayStyle)
        transactionListButton.setTitle("transaction.report.get.list".localized(), for: .normal)
        transactionByIdButton.apply(style: .globalPayStyle)
        transactionByIdButton.setTitle("transaction.report.get.by.id".localized(), for: .normal)
        activityIndicator.stopAnimating()
    }

    private func setupTable() {
        tableView.dataSource = self
        tableView.register(UINib(nibName: TransactionSummaryTableViewCell.identifier, bundle: nil),
                           forCellReuseIdentifier: TransactionSummaryTableViewCell.identifier)
        tableView.tableFooterView = UIView()
    }

    // MARK: - Actions

    @IBAction private func getTransactionListAction() {
        let form = TransactionListFormBuilder.build(with: self)
        navigationController?.present(form, animated: true, completion: nil)
    }

    @IBAction private func getTransactionByIdAction() {
        let form = TransactionByIDFormBuilder.build(with: self)
        navigationController?.present(form, animated: true, completion: nil)
    }
}

// MARK: - TransactionByIDFormDelegate

extension TransactionReportViewController: TransactionByIDFormDelegate {

    func onComletedForm(transactionID: String) {
        tableView.backgroundView = nil
        viewModel.clearViewModels()
        activityIndicator.startAnimating()
        viewModel.getTransactionByID(transactionID)
    }
}

// MARK: - TransactionListFormDelegate

extension TransactionReportViewController: TransactionListFormDelegate {

    func onSubmitForm(form: TransactionListForm) {
        tableView.backgroundView = nil
        viewModel.clearViewModels()
        activityIndicator.startAnimating()
        viewModel.getTransactions(form: form)
    }
}

// MARK: - TransactionReportViewOutput

extension TransactionReportViewController: TransactionReportViewOutput {

    func showErrorView(error: Error?) {
        activityIndicator.stopAnimating()
        let errorView = ErrorView.instantiateFromNib()
        errorView.display(error)
        tableView.backgroundView = errorView
    }

    func reloadData() {
        activityIndicator.stopAnimating()
        tableView.reloadData()
    }

    func displayEmptyView() {
        tableView.backgroundView = EmptyView.instantiateFromNib()
    }
}

// MARK: - UITableViewDataSource

extension TransactionReportViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.transactions.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: TransactionSummaryTableViewCell.identifier, for: indexPath) as! TransactionSummaryTableViewCell
        cell.setup(viewModel: viewModel.transactions[indexPath.row])
        return cell
    }
}
