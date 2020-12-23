import UIKit

struct VerificationsBuilder {

    static func build() -> UIViewController {
        let module = VerificationsViewController.instantiate()
        let viewModel = VerificationsViewModel()
        module.viewModel = viewModel
        viewModel.view = module

        return module
    }
}
