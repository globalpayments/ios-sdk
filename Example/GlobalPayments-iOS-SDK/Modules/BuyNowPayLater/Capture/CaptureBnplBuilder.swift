import UIKit

struct CaptureBnplBuilder {

    static func build(_ transactionId: String) -> UIViewController {
        let module = CaptureBnplViewController.instantiate()
        let viewModel = CaptureBnplViewModel(transactionId: transactionId)
        module.viewModel = viewModel
        viewModel.view = module
        return module
    }
}
