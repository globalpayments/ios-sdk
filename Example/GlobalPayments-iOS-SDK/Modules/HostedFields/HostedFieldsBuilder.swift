import UIKit

struct HostedFieldsBuilder {

    static func build() -> UIViewController {
        let module = HostedFieldsViewController.instantiate()
        let configuration = ConfigutationService()
        let viewModel = HostedFieldsViewModel(configuration: configuration)
        module.viewModel = viewModel
        viewModel.view = module
        return module
    }
}
