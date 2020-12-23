import UIKit

struct GlobalPayListBuilder {

    static func build() -> UIViewController {
        let module = GlobalPayViewController.instantiate()
        let navigationController = UINavigationController(rootViewController: module)

        return navigationController
    }
}
