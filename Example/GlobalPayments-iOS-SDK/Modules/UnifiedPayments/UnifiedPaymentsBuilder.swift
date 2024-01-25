import UIKit

struct UnifiedPaymentsBuilder {

    static func build() -> UIViewController {
        let module = UnifiedPaymentsViewController()
        let viewModel = UnifiedPaymentsViewModel()
        viewModel.viewController = module
        module.viewModel = viewModel
        return module
    }
}
