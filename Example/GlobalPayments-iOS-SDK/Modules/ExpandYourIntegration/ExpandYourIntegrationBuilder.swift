import UIKit

struct ExpandYourIntegrationBuilder {

    static func build() -> UIViewController {
        let module = ExpandYourIntegrationViewController()
        module.viewModel = ExpandYourIntegrationViewModel()
        return module
    }
}
