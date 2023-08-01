import UIKit
import GlobalPayments_iOS_SDK

struct CustomerBuilder {

    static func build(delegate: CustomerDelegate?, defaultData: Customer? = nil) -> UIViewController {
        let module = CustomerViewController.instantiate()
        module.delegate = delegate
        let viewModel = CustomerViewModel(customer: defaultData)
        module.viewModel = viewModel
        viewModel.view = module
        return module
    }
}
