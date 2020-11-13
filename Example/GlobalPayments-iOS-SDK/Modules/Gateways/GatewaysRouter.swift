import UIKit

struct GatewaysRouter: Router {

    private weak var navigationController: UINavigationController?

    init(navigationController: UINavigationController?) {
        self.navigationController = navigationController
    }

    func navigate(to destination: GatewayModel.Gateway) {
        let viewController = makeViewController(for: destination)
        navigationController?.pushViewController(viewController, animated: true)
    }

    private func makeViewController(for destination: Destination) -> UIViewController {
        switch destination {
        case .gpapi:
            return GlobalPayListBuilder.build()
        default:
            return UIViewController()
        }
    }
}
