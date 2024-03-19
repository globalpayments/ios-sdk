import UIKit

struct RetrieveFileBuilder {

    static func build() -> UIViewController {
        let module = RetrieveFileViewController()
        module.viewModel = RetrieveFileViewModel()
        return module
    }
}
