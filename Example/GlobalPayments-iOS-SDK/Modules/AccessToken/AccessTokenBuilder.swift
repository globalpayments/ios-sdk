import UIKit

struct AccessTokenBuilder {

    static func build() -> UIViewController {
        let module = AccessTokenViewController()
        let viewModel = AccessTokenViewModel()
        module.viewModel = viewModel
        return module
    }
}
