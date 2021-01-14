import UIKit

final class DisputesViewController: UIViewController, StoryboardInstantiable {

    static var storyboardName = "Disputes"

    lazy fileprivate var disputesRouterRouter: DisputesRouter = {
        return DisputesRouter(navigationController: navigationController)
    }()

    @IBOutlet private weak var tableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
    }

    private func setupUI() {
        title = "disputes.title".localized()
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

// MARK: - UITableViewDelegate

extension DisputesViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        DisputesModel.models.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: SelectableTableViewCell.identifier, for: indexPath) as! SelectableTableViewCell
        let model = DisputesModel.models[indexPath.row]
        cell.setupTitle(model.name)

        return cell
    }
}

// MARK: - UITableViewDelegate

extension DisputesViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let videModel = DisputesModel.models[indexPath.row]
        disputesRouterRouter.navigate(to: videModel.path)
    }
}
