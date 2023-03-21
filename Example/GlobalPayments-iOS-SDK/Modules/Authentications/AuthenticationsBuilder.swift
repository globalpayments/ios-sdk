import UIKit

struct AuthenticationsBuilder {

    static func build() -> UIViewController {
        let module = AuthenticationsViewController.instantiate()
        let viewModel = AuthenticationsViewModel()
        module.viewModel = viewModel
        viewModel.view = module

        return module
    }
}
