import UIKit

class ReportingViewModel: BaseViewModel {
    
    private lazy var titles = [
        "globalpay.transactions.title",
        "globalpay.deposits.title",
        "reporting.payment.methods.title",
        "reporting.actions.title",
        "reporting.disputes.title",
        "reporting.accounts.title"
    ]
    
    private lazy var descriptions = [
        "reporting.transactions.description",
        "reporting.deposits.description",
        "reporting.payment.methods.description",
        "reporting.actions.description",
        "reporting.disputes.description",
        "reporting.accounts.description"
    ]
    
    var loadSingleItems: Dynamic<[SingleItemEntity]> = Dynamic([])
    var paymentProcessItemAction: Dynamic<UIViewController?> = Dynamic(nil)

    override func viewDidLoad() {
        initHomeItems()
    }
    
    private func initHomeItems() {
        let items = titles.enumerated().map{ (index, element) in
            SingleItemEntity(
                title: titles[index].localized(),
                description: descriptions[index].localized(),
                index: index)
        }
        loadSingleItems.value = items
    }
    
    func singleItemAction(index: Int) {
        let actions = ReportingItemAction.allCases
        var viewController: UIViewController?
        switch actions[index] {
        case .transactions:
            viewController = TransactionReportBuilder.build()
        case .deposits:
            viewController = DepositsReportBuilder.build()
        case .paymentMethods:
            viewController = PaymentMethodReportBuilder.build()
        case .actions:
            viewController = ActionsBuilder.build()
        case .disputes:
            viewController = DisputeReportBuilder.build()
        case .accounts:
            viewController = AccountsBuilder.build()
        }
        paymentProcessItemAction.value = viewController
    }
}

enum ReportingItemAction: String, CaseIterable {
    
    case transactions
    case deposits
    case paymentMethods
    case actions
    case disputes
    case accounts
}
