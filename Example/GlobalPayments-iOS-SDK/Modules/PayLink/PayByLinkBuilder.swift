import UIKit

struct PayByLinkBuilder {

    static func build() -> UIViewController {
        let module = PayByLinkViewController()
        let viewModel = PayByLinkViewModel()
        module.viewModel = viewModel
        return module
    }
}
