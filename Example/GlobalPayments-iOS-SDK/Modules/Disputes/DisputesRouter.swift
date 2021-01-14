import UIKit

struct DisputesRouter: Router {

    private weak var navigationController: UINavigationController?

    init(navigationController: UINavigationController?) {
        self.navigationController = navigationController
    }

    func navigate(to destination: DisputesModel.Path) {
        let viewController = makeViewController(for: destination)
        navigationController?.pushViewController(viewController, animated: true)
    }

    private func makeViewController(for destination: DisputesModel.Path) -> UIViewController {
        switch destination {
        case .report:
            return DisputeReportBuilder.build()
        case .operations:
            return DisputesOperationsBuilder.build()
        }
    }
}
