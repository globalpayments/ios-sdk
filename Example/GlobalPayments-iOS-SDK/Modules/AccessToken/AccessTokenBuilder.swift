import UIKit

struct AccessTokenBuilder {

    static func build() -> UIViewController {
        let module = AccessTokenViewController.instantiate()
        let viewModel = AccessTokenViewModel()
        module.viewModel = viewModel
        viewModel.view = module

        return module
    }
}
