import UIKit

struct DepositsBuilder {

    static func build() -> UIViewController {
        let module = DepositsViewController.instantiate()
        let viewModel = DepositsViewModel()
        module.viewModel = viewModel
        viewModel.view = module

        return module
    }
}
