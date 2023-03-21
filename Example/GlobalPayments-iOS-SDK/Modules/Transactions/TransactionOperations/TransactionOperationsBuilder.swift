import UIKit

struct TransactionOperationsBuilder {

    static func build() -> UIViewController {
        let module = TransactionOperationsViewController.instantiate()
        let configuration = ConfigutationService()
        let viewModel = TransactionOperationsViewModel(configuration: configuration)
        module.viewModel = viewModel
        viewModel.view = module

        return module
    }
}
