import UIKit

struct AmountBuilder {

    static func build() -> UIViewController {
        let module = AmountViewController.instantiate()
        let viewModel = MerchantViewModel()
        module.viewModel = viewModel
        viewModel.view = module

        return UINavigationController(rootViewController: module)
    }
}
