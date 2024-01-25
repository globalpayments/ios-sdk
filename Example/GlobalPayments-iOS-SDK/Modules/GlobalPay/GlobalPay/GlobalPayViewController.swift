import UIKit

final class GlobalPayViewController: UIViewController, StoryboardInstantiable {

    static let storyboardName = "GlobalPay"

    var viewModel: GlobalPayViewInput!

    lazy fileprivate var globalPayRouter: GlobalPayRouter = {
        return GlobalPayRouter(navigationController: navigationController)
    }()

    @IBOutlet private weak var tableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
        viewModel.onViewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
    }

    private func setupUI() {
        title = "globalpay.title".localized()
        navigationItem.rightBarButtonItem = NavigationItems.settings(self, #selector(onSettingsAction)).button
        setupTable()
    }

    private func setupTable() {
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UINib(nibName: SelectableTableViewCell.identifier, bundle: nil),
                           forCellReuseIdentifier: SelectableTableViewCell.identifier)
        tableView.tableFooterView = UIView()
    }

    @objc private func onSettingsAction() {
        showConfigurationModule(.pageSheet)
    }

    private func showConfigurationModule(_ modalPresentationStyle: UIModalPresentationStyle) {
        let module = ConfigurationGBBuilder.build(with: self)
        module.modalPresentationStyle = modalPresentationStyle
        navigationController?.present(module, animated: true, completion: nil)
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

// MARK: - GlobalPayViewOutput

extension GlobalPayViewController: GlobalPayViewOutput {

    func displayConfigModule() {
        showConfigurationModule(.fullScreen)
    }

    func displayError(_ error: Error) {
        let message = String(format: NSLocalizedString("globalpay.container.failure", comment: ""), error.localizedDescription)
        showAlert(message: message)
    }
}

// MARK: - ConfigurationViewDelegate

extension GlobalPayViewController: ConfigurationDataViewDelegate {

    func onUpdateConfiguration() {
        viewModel.onUpdateConfig()
    }
}
