import UIKit

struct AccessTokenFormBuilder {

    static func build(delegate: AccessTokenFormDelegate) -> UIViewController {
        let module = AccessTokenFormViewController.instantiate()
        module.delegate = delegate

        return UINavigationController(rootViewController: module)
    }
}
