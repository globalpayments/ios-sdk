import UIKit

struct AchChargeFormBuilder {

    static func build(with delegate: AchChargeFormDelegate, by path: AchPath) -> UIViewController {
        let module =  AchChargeFormViewController.instantiate()
        module.path = path
        module.delegate = delegate
        return UINavigationController(rootViewController: module)
    }
}
