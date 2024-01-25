import UIKit

struct VerificationsFormBuilder {

    static func build() -> UIViewController {
        let module = VerificationsFormViewController()
        module.viewModel = VerificationsFormViewModel()
        return module
    }
}
