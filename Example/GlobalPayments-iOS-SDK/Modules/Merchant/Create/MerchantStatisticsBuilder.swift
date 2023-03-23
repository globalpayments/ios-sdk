import UIKit

struct MerchantStatisticsBuilder {

    static func build(_ delegate: MerchantStatisticsDelegate) -> UIViewController {
        let module = MerchantStatisticsController.instantiate()
        module.delegate = delegate
        return module
    }
}
