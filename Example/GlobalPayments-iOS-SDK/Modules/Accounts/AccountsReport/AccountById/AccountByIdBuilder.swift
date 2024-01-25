import UIKit

struct AccountByIdBuilder {

    static func build() -> UIViewController {
        let module = AccountByIdViewController()
        module.viewModel = AccountByIdViewModel()
        return module
    }
}
