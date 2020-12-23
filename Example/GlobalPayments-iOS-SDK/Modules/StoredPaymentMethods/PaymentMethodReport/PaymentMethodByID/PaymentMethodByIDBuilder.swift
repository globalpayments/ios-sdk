import UIKit

struct PaymentMethodByIDBuilder {

    static func build(with delegate: PaymentMethodByIDDelegate) -> UIViewController {
        let module = PaymentMethodByIDViewController.instantiate()
        module.delegate = delegate

        return UINavigationController(rootViewController: module)
    }
}
