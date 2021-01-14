import UIKit

final class DepositsViewController: UIViewController, StoryboardInstantiable {

    static var storyboardName = "Deposits"

    var viewModel: DepositsViewInput!

    @IBOutlet private weak var depositsListButton: UIButton!
    @IBOutlet private weak var depositButton: UIButton!
    @IBOutlet private weak var tableView: UITableView!
    @IBOutlet private weak var activityIndicator: UIActivityIndicatorView!

    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
    }

    private func setupUI() {
        title = "deposits.title".localized()
        hideKeyboardWhenTappedAround()

        depositsListButton.apply(style: .globalPayStyle, title: "deposits.get.deposits.list".localized())
        depositButton.apply(style: .globalPayStyle, title: "deposits.get.deposit.by.id".localized())

        activityIndicator.stopAnimating()

        setupTable()
    }

    private func setupTable() {
        tableView.dataSource = self
        tableView.register(UINib(nibName: DepositTableViewCell.identifier, bundle: nil),
                           forCellReuseIdentifier: DepositTableViewCell.identifier)
        tableView.tableFooterView = UIView()
    }

    // MARK: - Actions

    @IBAction private func onDepositsListAction() {
        let form = DepositsListFormBuilder.build(with: self)
        present(form, animated: true, completion: nil)
    }

    @IBAction private func onDepositByIdAction() {
        let form = DepositByIDFormBuilder.build(with: self)
        present(form, animated: true, completion: nil)
    }
}

// MARK: - DepositsViewOutput

extension DepositsViewController: DepositsViewOutput {

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

// MARK: - DepositByIDFormDelegate

extension DepositsViewController: DepositByIDFormDelegate {

    func onSubmitForm(_ form: DepositByIDForm) {
        tableView.backgroundView = nil
        viewModel.clearViewModels()
        activityIndicator.startAnimating()
        viewModel.getDeposit(form: form)
    }
}

// MARK: - DepositsListFormDelegate

extension DepositsViewController: DepositsListFormDelegate {

    func onSubmitForm(_ form: DepositsListForm) {
        tableView.backgroundView = nil
        viewModel.clearViewModels()
        activityIndicator.startAnimating()
        viewModel.getDeposits(form: form)
    }
}

// MARK: - UITableViewDataSource

extension DepositsViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.deposits.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: DepositTableViewCell.identifier, for: indexPath) as! DepositTableViewCell
        cell.setup(viewModel: viewModel.deposits[indexPath.row])

        return cell
    }
}
