import UIKit

struct AccessTokenRouter: Router {

    enum Path {
        case form(AccessTokenFormDelegate)
    }

    private weak var navigationController: UINavigationController?

    init(navigationController: UINavigationController?) {
        self.navigationController = navigationController
    }

    func navigate(to destination: Path) {
        switch destination {
        case .form(let delegate):
            let accessTokenForm = makeViewController(for: .form(delegate))
            navigationController?.present(accessTokenForm, animated: true, completion: nil)
        }
    }

    private func makeViewController(for destination: Path) -> UIViewController {
        switch destination {
        case .form(let delegate):
            return AccessTokenFormBuilder.build(delegate: delegate)
        }
    }
}
