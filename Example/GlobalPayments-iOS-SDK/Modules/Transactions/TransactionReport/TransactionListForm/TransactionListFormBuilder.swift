import UIKit

struct TransactionListFormBuilder {

    static func build(with delegate: TransactionListFormDelegate) -> UIViewController {
        let module = TransactionListFormViewController.instantiate()
        module.delegate = delegate

        return UINavigationController(rootViewController: module)
    }
}
