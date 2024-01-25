import UIKit

struct PaypalBuilder {

    static func build() -> UIViewController {
        let module = PaypalViewController()
        let viewModel = PaypalViewModel()
        module.viewModel = viewModel
        return module
    }
}
