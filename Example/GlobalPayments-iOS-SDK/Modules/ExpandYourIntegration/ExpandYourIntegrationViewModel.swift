import UIKit

class ExpandYourIntegrationViewModel: BaseViewModel {
    
    private lazy var titles = [
        "expand.stored.payment.methods.title",
        "expand.verifications.title",
        "expand.dispute.operations.title",
        "expand.batches.title",
        "expand.merchants.account.title",
        "file.proccessing.title.screen"
    ]
    
    private lazy var descriptions = [
        "expand.stored.payment.methods.description",
        "expand.verifications.description",
        "expand.dispute.operations.description",
        "expand.batches.description",
        "expand.edit.account.description",
        "expand.file.processing.description"
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
        let actions = ExpandYourIntegrationItemAction.allCases
        var viewController: UIViewController?
        switch actions[index] {
        case .paymentMethods:
            viewController = PaymentOperationFormBuilder.build()
        case .verifications:
            viewController = VerificationsFormBuilder.build()
        case .disputeOperations:
            viewController = DisputesOperationsFormBuilder.build()
        case .batches:
            viewController = BatchBuilder.build()
        case .editAccount:
            viewController = MerchantPagesBuilder.build()
        case .fileProccessing:
            viewController = FileProcessingBuilder.build()
        }
        paymentProcessItemAction.value = viewController
    }
}

enum ExpandYourIntegrationItemAction: String, CaseIterable {
    
    case paymentMethods
    case verifications
    case disputeOperations
    case batches
    case editAccount
    case fileProccessing
}

