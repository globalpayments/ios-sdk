import UIKit

struct CheckAvailabilityFormBuilder {

    static func build(with delegate: CheckAvailabilityFormDelegate) -> UIViewController {
        let module = CheckAvailabilityFormViewController.instantiate()
        module.delegate = delegate

        return UINavigationController(rootViewController: module)
    }
}
