import UIKit

struct DisputeListFormBuilder {

    static func build() -> UIViewController {
        let module = DisputeListFormViewController()
        module.viewModel = DisputeListFormViewModel()
        return module
    }
}
