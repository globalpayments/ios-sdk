import UIKit

struct PaymentMethodsRouter: Router {

    private weak var navigationController: UINavigationController?

    init(navigationController: UINavigationController?) {
        self.navigationController = navigationController
    }

    func navigate(to destination: PaymentMethodsModel.Path) {
        let viewController = makeViewController(for: destination)
        navigationController?.pushViewController(viewController, animated: true)
    }

    private func makeViewController(for destination: PaymentMethodsModel.Path) -> UIViewController {
        switch destination {
        case .report:
            return PaymentMethodReportBuilder.build()
        case .operations:
            return PaymentMethodOperationsBuilder.build()
        }
    }
}
