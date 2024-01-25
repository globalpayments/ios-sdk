import UIKit

struct ActionByIdBuilder {

    static func build() -> UIViewController {
        let module = ActionByIdViewController()
        module.viewModel = ActionByIdViewModel()
        return module
    }
}
