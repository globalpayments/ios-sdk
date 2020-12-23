import UIKit
import GlobalPayments_iOS_SDK

final class DisputeDocumentViewController: UIViewController, StoryboardInstantiable {

    static var storyboardName = "Disputes"

    var documents: [DisputeDocument]?

    @IBOutlet private weak var tableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        tableView.reloadData()
    }

    private func setupUI() {
        title = "dispute.document.title".localized()
        navigationItem.rightBarButtonItem = NavigationItems.cancel(self, #selector(onCancelAction)).button

        setupTableView()
    }

    private func setupTableView() {
        tableView.register(UINib(nibName: DocumentTableViewCell.identifier, bundle: nil),
                           forCellReuseIdentifier: DocumentTableViewCell.identifier)
        tableView.dataSource = self
        tableView.tableFooterView = UIView()
    }

    // MARK: - Actions

    @objc private func onCancelAction() {
        dismiss(animated: true, completion: nil)
    }
}

// MARK: - UITableViewDataSource

extension DisputeDocumentViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return documents?.count ?? .zero
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: DocumentTableViewCell.identifier, for: indexPath) as! DocumentTableViewCell
        if let viewModel = documents?[indexPath.row] {
            cell.setup(viewModel: viewModel)
        }

        return cell
    }
}
