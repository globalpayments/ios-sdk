import UIKit

struct DisputeListFormBuilder {

    static func build(with delegate: DisputeListFormDelegate) -> UIViewController {
        let module = DisputeListFormViewController.instantiate()
        module.delegate = delegate

        return UINavigationController(rootViewController: module)
    }
}
