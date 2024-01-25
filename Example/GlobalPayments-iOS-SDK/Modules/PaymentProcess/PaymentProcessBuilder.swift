import UIKit

struct PaymentProcessBuilder {

    static func build() -> UIViewController {
        let module = PaymentProcessViewController()
        module.viewModel = PaymentProcessViewModel()
        return module
    }
}
