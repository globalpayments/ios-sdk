import UIKit

struct ConfigurationGBBuilder {

    static func build(with delegate: ConfigurationDataViewDelegate) -> UIViewController {
        let module = ConfigurationViewController()
        module.delegate = delegate
        let configuration = ConfigutationService()
        let viewModel = ConfigurationViewModel(configuration: configuration)
        module.viewModel = viewModel
        return UINavigationController(rootViewController: module)
    }
}
