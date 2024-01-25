import UIKit

struct BatchBuilder {

    static func build() -> UIViewController {
        let module = BatchViewController()
        module.viewModel = BatchViewModel()
        return module
    }
}
