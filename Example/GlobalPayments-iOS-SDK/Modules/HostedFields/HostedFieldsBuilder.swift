import UIKit

struct HostedFieldsBuilder {

    static func build() -> UIViewController {
        let module = HostedFieldsViewController()
        let configuration = ConfigutationService()
        let viewModel = HostedFieldsViewModel(configuration: configuration)
        viewModel.viewController = module
        module.viewModel = viewModel
        viewModel.viewController = module
        return module
    }
}
