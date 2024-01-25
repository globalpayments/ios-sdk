import UIKit

struct GlobalPayHomeBuilder {

    static func build() -> UIViewController {
        let module = GlobalPayHomeViewController()
        module.viewModel = GlobalPayHomeViewModel()
        return UINavigationController(rootViewController: module)
    }
}
