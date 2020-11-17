import UIKit

struct TransactionsRouter: Router {

    private weak var navigationController: UINavigationController?

    init(navigationController: UINavigationController?) {
        self.navigationController = navigationController
    }

    func navigate(to destination: TransactionModel.Path) {
        let viewController = makeViewController(for: destination)
        navigationController?.pushViewController(viewController, animated: true)
    }

    private func makeViewController(for destination: TransactionModel.Path) -> UIViewController {
        switch destination {
        case .report:
            return TransactionReportBuilder.build()
        case .operations:
            return UIViewController.empty()
        }
    }
}
