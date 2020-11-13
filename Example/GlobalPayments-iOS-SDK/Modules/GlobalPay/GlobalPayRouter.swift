import UIKit

struct GlobalPayRouter: Router {

    private weak var navigationController: UINavigationController?

    init(navigationController: UINavigationController?) {
        self.navigationController = navigationController
    }

    func navigate(to destination: GlobalPayModel.Path) {
        let viewController = makeViewController(for: destination)
        navigationController?.pushViewController(viewController, animated: true)
    }

    private func makeViewController(for destination: Destination) -> UIViewController {

//        switch destination {
//        case .globalPayments:
////            let flightDetailsController = FlightDetailsViewController.instantiate()
////            flightDetailsController.setupFlight(flight)
//
//        }
        return UIViewController()
    }
}
