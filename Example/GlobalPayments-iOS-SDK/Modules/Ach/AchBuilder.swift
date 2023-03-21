import UIKit

struct AchBuilder {

    static func build() -> UIViewController {
        let module = AchViewController.instantiate()
        let viewModel = AchViewModel()
        module.viewModel = viewModel
        viewModel.view = module

        return module
    }
}
