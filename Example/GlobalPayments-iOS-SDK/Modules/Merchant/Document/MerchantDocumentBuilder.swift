import Foundation

import UIKit

struct MerchantDocumentBuilder {

    static func build() -> UIViewController {
        let module = MerchantDocumentViewController()
        module.viewModel = MerchantDocumentViewModel()
        return module
    }
}
