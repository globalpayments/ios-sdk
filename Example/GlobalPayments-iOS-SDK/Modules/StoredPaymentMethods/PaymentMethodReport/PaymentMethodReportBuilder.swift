import UIKit

struct PaymentMethodReportBuilder {

    static func build() -> UIViewController {
        let module = PaymentMethodReportViewController.instantiate()
        let viewModel = PaymentMethodReportViewModel()
        module.viewModel = viewModel
        viewModel.view = module

        return module
    }
}
