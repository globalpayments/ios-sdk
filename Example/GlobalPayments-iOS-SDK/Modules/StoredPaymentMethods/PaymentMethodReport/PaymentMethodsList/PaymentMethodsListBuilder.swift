import UIKit

struct PaymentMethodsListBuilder {

    static func build() -> UIViewController {
        let module = PaymentMethodsListViewController()
        module.viewModel = PaymentMethodsListViewModel()
        return module
    }
}

