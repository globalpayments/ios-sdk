import UIKit

struct MerchantEditBuilder {

    static func build() -> UIViewController {
        let module = MerchantEditViewController()
        module.viewModel = MerchantEditViewModel()
        return module
    }
}

