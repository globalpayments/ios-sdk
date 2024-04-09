import UIKit

struct AliPayBuilder {

    static func build() -> UIViewController {
        let module = AliPayViewController()
        let viewModel = AliPayViewModel()
        module.viewModel = viewModel
        return module
    }
}
