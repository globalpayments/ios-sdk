import UIKit

struct BuyNowPayLaterBuilder {

    static func build() -> UIViewController {
        let module = BuyNowPayLaterViewController.instantiate()
        let viewModel = BuyNowPayLaterViewModel()
        module.viewModel = viewModel
        viewModel.view = module

        return module
    }
}
