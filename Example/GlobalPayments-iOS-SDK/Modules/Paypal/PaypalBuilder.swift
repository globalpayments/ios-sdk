import UIKit

struct PaypalBuilder {

    static func build() -> UIViewController {
        let module = PaypalViewController.instantiate()
        let viewModel = PaypalViewModel()
        module.viewModel = viewModel
        viewModel.view = module

        return module
    }
}
