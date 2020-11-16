import UIKit

struct GatewaysListBuilder {

    static func build() -> UIViewController {
        let viewController = GatewaysViewController.instantiate()
        let navigationController = UINavigationController(rootViewController: viewController)

        return navigationController
    }
}
