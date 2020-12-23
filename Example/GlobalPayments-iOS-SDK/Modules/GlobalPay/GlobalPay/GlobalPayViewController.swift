import UIKit

final class GlobalPayViewController: UIViewController, StoryboardInstantiable {

    static let storyboardName = "GlobalPay"

    lazy fileprivate var globalPayRouter: GlobalPayRouter = {
        return GlobalPayRouter(navigationController: navigationController)
    }()

    @IBOutlet private weak var tableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
    }

    private func setupUI() {
        title = "globalpay.title".localized()
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

extension GlobalPayViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return GlobalPayModel.models.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: SelectableTableViewCell.identifier, for: indexPath) as! SelectableTableViewCell
        let model = GlobalPayModel.models[indexPath.row]
        cell.setupTitle(model.name)

        return cell
    }
}

// MARK: - UITableViewDelegate

extension GlobalPayViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let videModel = GlobalPayModel.models[indexPath.row]
        globalPayRouter.navigate(to: videModel.path)
    }
}
