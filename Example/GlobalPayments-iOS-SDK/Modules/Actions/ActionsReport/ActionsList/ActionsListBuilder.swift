import UIKit

struct ActionsListBuilder {

    static func build() -> UIViewController {
        let module = ActionsListViewController()
        module.viewModel = ActionsListViewModel()
        return module
    }
}
