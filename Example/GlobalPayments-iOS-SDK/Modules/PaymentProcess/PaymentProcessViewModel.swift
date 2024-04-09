import UIKit

class PaymentProcessViewModel: BaseViewModel {
    
    private lazy var titles = [
        "globalpay.hosted.fields.title",
        "payment.process.unified.payments.title",
        "globalpay.apple.pay",
        "paypal.title",
        "globalpay.paylink.title",
        "globalpay.ach.title",
        "globalpay.ebt.title",
        "buyNowPayLater.title",
        "globalpay.alipay.title"
    ]
    
    private lazy var descriptions = [
        "payment.process.hosted.fields.description",
        "payment.process.unified.payments.description",
        "payment.process.apple.pay.description",
        "payment.process.paypal.description",
        "payment.process.paylink.description",
        "payment.process.ach.description",
        "payment.process.ebt.description",
        "payment.process.bnpl.description",
        "payment.process.ali.pay.description"
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
        let actions = PaymentItemAction.allCases
        var viewController: UIViewController?
        switch actions[index] {
        case .hostedFields:
            viewController = HostedFieldsBuilder.build()
        case .unifiedPayments:
            viewController = UnifiedPaymentsBuilder.build()
        case .applePay:
            viewController = DigitalWalletsBuilder.build()
        case .paypal:
            viewController = PaypalBuilder.build()
        case .payLink:
            viewController = PayLinkBuilder.build()
        case .ach:
            viewController = AchBuilder.build()
        case .ebt:
            viewController = EbtBuilder.build()
        case .bnpl:
            viewController = BuyNowPayLaterBuilder.build()
        case .aliPay:
            viewController = AliPayBuilder.build()
        }
        paymentProcessItemAction.value = viewController
    }
}

enum PaymentItemAction: String, CaseIterable {
    
    case hostedFields
    case unifiedPayments
    case applePay
    case paypal
    case payLink
    case ach
    case ebt
    case bnpl
    case aliPay
}
