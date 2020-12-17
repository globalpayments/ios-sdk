import UIKit

struct TransactionOperationsFormBuilder {

    static func build(with delegate: TransactionOperationsFormDelegate) -> UIViewController {
        let module = TransactionOperationsFormViewController.instantiate()
        module.delegate = delegate

        return UINavigationController(rootViewController: module)
    }
}
