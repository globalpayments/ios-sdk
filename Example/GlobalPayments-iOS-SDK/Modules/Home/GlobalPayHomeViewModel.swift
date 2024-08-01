import UIKit
import GlobalPayments_iOS_SDK

class GlobalPayHomeViewModel: BaseViewModel {
    
    private lazy var homeTitles = [
        "access.token.create",
        "home.process.payment.title",
        "home.expand.integration.title",
        "home.reporting.title"
    ]
    
    private lazy var homeDescriptions = [
        "home.create.token.description",
        "home.process.payment.description",
        "home.expand.integration.description",
        "home.reporting.description"
    ]
    
    private lazy var homeImages = [#imageLiteral(resourceName: "ic_access_token"), #imageLiteral(resourceName: "ic_payments"), #imageLiteral(resourceName: "ic_integration"), #imageLiteral(resourceName: "ic_reporting")]
    
    var loadHomeItems: Dynamic<[HomeItemEntity]> = Dynamic([])
    var homeItemAction: Dynamic<UIViewController?> = Dynamic(nil)

    override func viewDidLoad() {
        super.viewDidLoad()
        initHomeItems()
    }
    
    private func initHomeItems() {
        let items = homeTitles.enumerated().map{ (index, element) in
            HomeItemEntity(
                title: homeTitles[index].localized(),
                image: homeImages[index],
                description: homeDescriptions[index].localized(),
                index: index)
        }
        loadHomeItems.value = items
    }
    
    func homeItemAction(index: Int) {
        let actions = HomeItemAction.allCases
        var viewController: UIViewController?
        switch actions[index] {
        case .createAccessToken:
            viewController = AccessTokenBuilder.build()
        case .processPayment:
            viewController = PaymentProcessBuilder.build()
        case .expandIntegration:
            viewController = ExpandYourIntegrationBuilder.build()
        case .reporting:
            viewController = ReportingBuilder.build()
        }
        homeItemAction.value = viewController
    }
}

enum HomeItemAction: String, CaseIterable {
    
    case createAccessToken
    case processPayment
    case expandIntegration
    case reporting
}
