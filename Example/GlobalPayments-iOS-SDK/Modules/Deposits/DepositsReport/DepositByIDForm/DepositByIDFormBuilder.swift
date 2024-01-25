import UIKit

struct DepositByIDFormBuilder {

    static func build() -> UIViewController {
        let module = DepositByIDFormViewController()
        module.viewModel = DepositByIdFormViewModel()
        return module
    }
}
