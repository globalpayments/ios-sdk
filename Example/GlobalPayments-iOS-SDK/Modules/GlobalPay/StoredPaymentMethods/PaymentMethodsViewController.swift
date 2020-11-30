import UIKit

final class PaymentMethodsViewController: UIViewController, StoryboardInstantiable {

    static var storyboardName = "PaymentMethods"

    lazy fileprivate var paymentMethodsRouter: PaymentMethodsRouter = {
        return PaymentMethodsRouter(navigationController: navigationController)
    }()

    @IBOutlet private weak var tableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
    }

    private func setupUI() {
        title = "payment.methods.title".localized()
        setupTable()
    }

    private func setupTable() {
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UINib(nibName: SelectableTableViewCell.identifier, bundle: nil),
                           forCellReuseIdentifier: SelectableTableViewCell.identifier)
        tableView.tableFooterView = UIView()
    }
}

// MARK: - UITableViewDataSource

extension PaymentMethodsViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        PaymentMethodsModel.models.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: SelectableTableViewCell.identifier, for: indexPath) as! SelectableTableViewCell
        let model = PaymentMethodsModel.models[indexPath.row]
        cell.setupTitle(model.name)

        return cell
    }
}

// MARK: - UITableViewDelegate

extension PaymentMethodsViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let videModel = PaymentMethodsModel.models[indexPath.row]
        paymentMethodsRouter.navigate(to: videModel.path)
    }
}
