import UIKit

struct PaymentMethodOperationsBuilder {

    static func build() -> UIViewController {
        let module = PaymentMethodOperationsViewController.instantiate()
        let viewModel = PaymentMethodOperationsViewModel()
        module.viewModel = viewModel
        viewModel.view = module

        return module
    }
}
