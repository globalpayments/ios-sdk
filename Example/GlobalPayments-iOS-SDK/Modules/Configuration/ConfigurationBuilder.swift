import UIKit

struct ConfigurationBuilder {

    static func build() -> UIViewController {
        let module = ConfigurationViewController.instantiate()
        let configuration = ConfigutationService()
        let viewModel = ConfigurationViewModel(configuration: configuration)
        module.viewModel = viewModel
        viewModel.view = module

        return UINavigationController(rootViewController: module)
    }
}
