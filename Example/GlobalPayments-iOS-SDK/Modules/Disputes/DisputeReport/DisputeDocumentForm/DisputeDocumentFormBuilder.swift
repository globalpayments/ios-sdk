import UIKit

struct DisputeDocumentFormBuilder {

    static func build(with delegate: DisputeDocumentFormDelegate) -> UIViewController {
        let module = DisputeDocumentFormViewController.instantiate()
        module.delegate = delegate

        return UINavigationController(rootViewController: module)
    }
}
