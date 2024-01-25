import UIKit

struct DisputesOperationsFormBuilder {

    static func build() -> UIViewController {
        let module = DisputesOperationsFormViewController()
        module.viewModel = DisputesOperationsFormViewModel()
        return module
    }
}
