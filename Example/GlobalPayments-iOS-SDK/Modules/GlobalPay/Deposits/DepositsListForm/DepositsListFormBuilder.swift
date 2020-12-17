import UIKit

struct DepositsListFormBuilder {

    static func build(with delegate: DepositsListFormDelegate) -> UIViewController {
        let module = DepositsListFormViewController.instantiate()
        module.delegate = delegate

        return UINavigationController(rootViewController: module)
    }
}
