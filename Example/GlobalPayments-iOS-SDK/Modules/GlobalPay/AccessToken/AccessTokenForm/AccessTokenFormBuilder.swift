import UIKit

struct AccessTokenFormBuilder {

    static func build(delegate: AccessTokenFormDelegate) -> UIViewController {
        let module = AccessTokenFormViewController.instantiate()
        module.delegate = delegate
//        let viewModel = AccessTokenViewModel()
//        module.viewModel = viewModel
//        viewModel.view = module

        return module
    }
}
