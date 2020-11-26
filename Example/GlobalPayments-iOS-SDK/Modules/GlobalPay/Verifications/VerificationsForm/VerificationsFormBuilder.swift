import UIKit

struct VerificationsFormBuilder {

    static func build(with delegate: VerificationsFormDelegate) -> UIViewController {
        let module = VerificationsFormViewController.instantiate()
        module.delegate = delegate

        return module
    }
}
