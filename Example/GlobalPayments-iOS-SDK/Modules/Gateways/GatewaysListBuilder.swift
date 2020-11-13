import UIKit

struct GatewaysListBuilder: ModuleBuilder {

    static func build() -> UIViewController {
        let viewController = GatewaysViewController.instantiate()
        let navigationController = UINavigationController(rootViewController: viewController)

        return navigationController
    }
}
