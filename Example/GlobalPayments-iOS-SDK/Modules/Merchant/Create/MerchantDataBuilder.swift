import UIKit

struct MerchantDataBuilder {

    static func build(_ delegate: MerchantDataDelegate) -> UIViewController {
        let module = MerchantDataViewController.instantiate()
        module.delegate = delegate
        let viewModel = MerchantDataViewModel()
        viewModel.view = module
        module.viewModel = viewModel
        return module
    }
}

