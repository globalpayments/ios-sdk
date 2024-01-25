import UIKit

struct BuyNowPayLaterBuilder {

    static func build() -> UIViewController {
        let module = BuyNowPayLaterViewController()
        let viewModel = BuyNowPayLaterViewModel()
        module.viewModel = viewModel
        return module
    }
}
