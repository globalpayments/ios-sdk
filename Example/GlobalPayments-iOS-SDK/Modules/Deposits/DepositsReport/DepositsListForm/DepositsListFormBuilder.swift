import UIKit

struct DepositsListFormBuilder {

    static func build() -> UIViewController {
        let module = DepositsListFormViewController()
        module.viewModel = DepositsListFormViewModel()
        return module
    }
}
