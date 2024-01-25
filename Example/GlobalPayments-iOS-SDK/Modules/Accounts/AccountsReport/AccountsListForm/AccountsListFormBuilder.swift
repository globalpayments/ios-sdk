import UIKit

struct AccountsListFormBuilder {

    static func build() -> UIViewController {
        let module = AccountsListFormViewController()
        module.viewModel = AccountsListFormViewModel()
        return module
    }
}
