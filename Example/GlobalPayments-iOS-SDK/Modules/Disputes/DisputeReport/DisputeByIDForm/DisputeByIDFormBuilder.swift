import UIKit

struct DisputeByIDFormBuilder {

    static func build(with delegate: DisputeByIDFormDelegate) -> UIViewController {
        let module = DisputeByIDFormViewController.instantiate()
        module.delegate = delegate

        return UINavigationController(rootViewController: module)
    }
}
