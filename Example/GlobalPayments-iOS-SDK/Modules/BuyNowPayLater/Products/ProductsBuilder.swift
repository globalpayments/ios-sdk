import UIKit
import GlobalPayments_iOS_SDK

struct ProductsBuilder {

    static func build(_ delegate: ProductsDelegate?, selectedProducts: [Product]?) -> UIViewController {
        let module = ProductsViewController.instantiate()
        module.delegate = delegate
        let viewModel = ProductsViewModel()
        viewModel.selectedProducts = selectedProducts
        module.viewModel = viewModel
        viewModel.view = module
        return module
    }
}
