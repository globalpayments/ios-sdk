import UIKit

struct DisputesOperationsFormBuilder {

    static func build(with delegate: DisputesOperationsFormDelegate) -> UIViewController {
        let module = DisputesOperationsFormViewController.instantiate()
        module.delegate = delegate

        return UINavigationController(rootViewController: module)
    }
}
