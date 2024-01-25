import UIKit

struct DigitalWalletsBuilder {

    static func build() -> UIViewController {
        let module = DigitalWalletsViewController()
        module.viewModel = DigitalWalletsViewModel()
        return module
    }
}
