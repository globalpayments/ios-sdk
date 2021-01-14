import UIKit

struct ConfigurationBuilder {

    static func build(with delegate: ConfigurationViewDelegate) -> UIViewController {
        let module = ConfigurationViewController.instantiate()
        module.delegate = delegate
        let configuration = ConfigutationService()
        let viewModel = ConfigurationViewModel(configuration: configuration)
        module.viewModel = viewModel
        viewModel.view = module

        return UINavigationController(rootViewController: module)
    }
}
