import UIKit

struct DisputeReportBuilder {

    static func build() -> UIViewController {
        let module = DisputeReportViewController.instantiate()
        let viewModel = DisputeReportViewModel()
        module.viewModel = viewModel
        viewModel.view = module

        return module
    }
}
