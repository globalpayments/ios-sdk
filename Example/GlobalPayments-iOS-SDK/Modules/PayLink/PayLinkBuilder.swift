import UIKit

struct PayLinkBuilder {

    static func build() -> UIViewController {
        let module = PayLinkViewController.instantiate()
        let viewModel = PayLinkViewModel()
        module.viewModel = viewModel
        viewModel.view = module

        return module
    }
}
