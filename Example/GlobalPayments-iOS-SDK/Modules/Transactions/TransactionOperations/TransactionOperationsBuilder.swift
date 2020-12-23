import UIKit

struct TransactionOperationsBuilder {

    static func build() -> UIViewController {
        let module = TransactionOperationsViewController.instantiate()
        let viewModel = TransactionOperationsViewModel()
        module.viewModel = viewModel
        viewModel.view = module

        return module
    }
}
