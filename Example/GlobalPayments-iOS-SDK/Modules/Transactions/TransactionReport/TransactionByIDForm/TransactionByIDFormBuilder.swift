import UIKit

struct TransactionByIDFormBuilder {

    static func build(with delegate: TransactionByIDFormDelegate) -> UIViewController {
        let module = TransactionByIDFormViewController.instantiate()
        module.delegate = delegate

        return UINavigationController(rootViewController: module)
    }
}
