import UIKit

struct DepositByIDFormBuilder {

    static func build(with delegate: DepositByIDFormDelegate) -> UIViewController {
        let module = DepositByIDFormViewController.instantiate()
        module.delegate = delegate

        return module
    }
}
