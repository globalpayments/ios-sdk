import UIKit

struct AchBuilder {

    static func build() -> UIViewController {
        let module = AchViewController()
        let viewModel = AchViewModel()
        module.viewModel = viewModel
        return module
    }
}
