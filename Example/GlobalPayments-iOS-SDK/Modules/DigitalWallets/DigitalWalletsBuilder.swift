import UIKit

struct DigitalWalletsBuilder {

    static func build() -> UIViewController {
        let module = DigitalWalletsViewController.instantiate()
//        let viewModel = AuthenticationsViewModel()
//        module.viewModel = viewModel
//        viewModel.view = module

        return module
    }
}
