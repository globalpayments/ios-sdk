import UIKit

struct TransactionReportBuilder {

    static func build() -> UIViewController {
        let module = TransactionReportViewController.instantiate()
        let viewModel = TransactionReportViewModel()
        module.viewModel = viewModel
        viewModel.view = module

        return module
    }
}
