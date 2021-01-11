import UIKit

struct TransactionReportBuilder {

    static func build() -> UIViewController {
        let module = TransactionReportViewController.instantiate()
        let configuration = ConfigutationService()
        let viewModel = TransactionReportViewModel(configuration: configuration)
        module.viewModel = viewModel
        viewModel.view = module

        return module
    }
}
