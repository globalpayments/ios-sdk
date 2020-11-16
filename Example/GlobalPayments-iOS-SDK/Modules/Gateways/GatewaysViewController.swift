import UIKit

final class GatewaysViewController: UIViewController, StoryboardInstantiable {

    static let storyboardName = "Gateways"

    lazy fileprivate var gatewaysRouter: GatewaysRouter = {
        return GatewaysRouter(navigationController: navigationController)
    }()

    @IBOutlet private weak var tableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
    }

    private func setupUI() {
        title = "gateways.title".localized()
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

extension GatewaysViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return GatewayModel.models.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: SelectableTableViewCell.identifier, for: indexPath) as! SelectableTableViewCell
        let model = GatewayModel.models[indexPath.row]
        cell.setupTitle(model.name)

        return cell
    }
}

// MARK: - UITableViewDelegate

extension GatewaysViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let videModel = GatewayModel.models[indexPath.row]
        switch videModel.identifier {
        case .gpapi:
            gatewaysRouter.navigate(to: .gpapi)
        case .portico:
            showAlert(message: "generic.not.implemented".localized())
        case .realex:
            showAlert(message: "generic.not.implemented".localized())
        }
    }
}
