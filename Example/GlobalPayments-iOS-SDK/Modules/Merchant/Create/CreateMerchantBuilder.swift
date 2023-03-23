import UIKit

struct CreateMerchantBuilder {

    static func build() -> UIViewController {
        let module = CreateMerchantViewController.instantiate()
        let viewModel = CreateMerchantViewModel()
        viewModel.view = module
        module.viewModel = viewModel
        return module
    }
}
