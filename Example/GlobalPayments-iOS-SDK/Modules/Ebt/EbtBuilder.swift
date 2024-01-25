import UIKit

struct EbtBuilder {

    static func build() -> UIViewController {
        let module = EbtViewController()
        let viewModel = EbtViewModel()
        module.viewModel = viewModel
        return module
    }
}
