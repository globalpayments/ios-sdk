import UIKit

struct DisputeByIDFormBuilder {

    static func build() -> UIViewController {
        let module = DisputeByIDFormViewController()
        module.viewModel = DisputeByIdFormViewModel()
        return module
    }
}
