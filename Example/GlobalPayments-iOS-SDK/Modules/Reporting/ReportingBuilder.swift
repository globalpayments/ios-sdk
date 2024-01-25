import UIKit

struct ReportingBuilder {

    static func build() -> UIViewController {
        let module = ReportingViewController()
        module.viewModel = ReportingViewModel()
        return module
    }
}
