import UIKit

struct MerchantAddressBuilder {

    static func build(delegate: MerchantAddressDelegate, path: MerchantAddressPath) -> UIViewController {
        let module = MerchantAddressViewController.instantiate()
        module.delegate = delegate
        module.path = path
        return module
    }
}
