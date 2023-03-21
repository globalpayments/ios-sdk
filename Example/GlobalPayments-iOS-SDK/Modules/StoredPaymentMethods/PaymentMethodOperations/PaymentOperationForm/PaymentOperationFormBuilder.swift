import UIKit

struct PaymentOperationFormBuilder {

    static func build(with delegate: PaymentOperationFormDelegate) -> UIViewController {
        let module = PaymentOperationFormViewController.instantiate()
        module.delegate = delegate

        return UINavigationController(rootViewController: module)
    }
}
