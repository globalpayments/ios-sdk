import UIKit
import GlobalPayments_iOS_SDK

struct DisputeDocumentBuilder {

    static func build(with documents: [DisputeDocument]?) -> UIViewController {
        let module = DisputeDocumentViewController.instantiate()
        module.documents = documents

        return UINavigationController(rootViewController: module)
    }
}
