import UIKit

struct AuthenticationDataFormBuilder {

    static func build(with delegate: AuthenticationDataFormDelegate) -> UIViewController {
        let module = AuthenticationDataFormViewController.instantiate()
        module.delegate = delegate

        return UINavigationController(rootViewController: module)
    }
}
