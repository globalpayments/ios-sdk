import UIKit

struct HostedFieldsWebViewBuilder {

    static func build(_ token: String, delegate: TokenizedCardDataDelegate) -> UIViewController {
        let module = HostedFieldsWebViewController.instantiate()
        module.token = token
        module.delegate = delegate
        return UINavigationController(rootViewController: module)
    }
}
