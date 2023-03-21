import UIKit

struct GlobalPayListBuilder {

    static func build() -> UIViewController {
        let module = GlobalPayViewController.instantiate()
        let configuration = ConfigutationService()
        let viewModel = GlobalPayViewModel(configuration: configuration)
        module.viewModel = viewModel
        viewModel.view = module

        return UINavigationController(rootViewController: module)
    }
}
