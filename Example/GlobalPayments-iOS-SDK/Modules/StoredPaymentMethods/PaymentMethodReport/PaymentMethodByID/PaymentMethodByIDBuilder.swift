import UIKit

struct PaymentMethodByIDBuilder {

    static func build() -> UIViewController {
        let module = PaymentMethodByIDViewController()
        module.viewModel = PaymentMethodByIDViewModel()
        return module
    }
}
