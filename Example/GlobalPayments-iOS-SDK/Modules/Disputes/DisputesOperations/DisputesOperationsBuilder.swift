import UIKit

struct DisputesOperationsBuilder {

    static func build() -> UIViewController {
        let module = DisputesOperationsViewController.instantiate()
        let viewModel = DisputesOperationsViewModel()
        module.viewModel = viewModel
        viewModel.view = module

        return module
    }
}
