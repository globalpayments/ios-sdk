import UIKit

struct PayLinkBuilder {

    static func build() -> UIViewController {
        let module = PayLinkViewController()
        let viewModel = PayLinkViewModel()
        module.viewModel = viewModel
        return module
    }
}
