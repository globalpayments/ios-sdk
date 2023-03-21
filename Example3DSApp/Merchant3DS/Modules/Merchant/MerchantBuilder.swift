import UIKit

struct MerchantBuilder {

    static func build(_ token: String, delegate: TokenizedCardDataDelegate) -> UIViewController {
        let module = MerchantViewController.instantiate()
        module.token = token
        module.delegate = delegate
        return UINavigationController(rootViewController: module)
    }
}
