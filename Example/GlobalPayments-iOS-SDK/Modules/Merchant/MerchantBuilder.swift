import UIKit

struct MerchantBuilder {

    static func build() -> UIViewController {
        let module = MerchantViewController.instantiate()
        let viewModel = MerchantViewModel()
        viewModel.view = module
        module.viewModel = viewModel
        return module
    }
}

