import UIKit

struct PaymentOperationFormBuilder {

    static func build() -> UIViewController {
        let module = PaymentOperationFormViewController()
        module.viewModel = PaymentOperationFormViewModel()
        return module
    }
}
