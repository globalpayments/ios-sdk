import UIKit

struct TransactionListFormBuilder {

    static func build() -> UIViewController {
        let module = TransactionListFormViewController()
        module.viewModel = TransactionListFormViewModel()
        return module
    }
}
