import UIKit

struct TransactionByIDFormBuilder {

    static func build() -> UIViewController {
        let module = TransactionByIDFormViewController()
        module.viewModel = TransactionByIdFormViewModel()
        return module
    }
}
