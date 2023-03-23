import UIKit

struct MerchantProductsBuilder {

    static func build(_ delegate: MerchantProductsDelegate) -> UIViewController {
        let module = MerchantProductsViewController.instantiate()
        module.delegate = delegate
        return module
    }
}
