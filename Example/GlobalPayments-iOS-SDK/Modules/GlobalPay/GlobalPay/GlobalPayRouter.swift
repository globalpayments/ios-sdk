import UIKit

struct GlobalPayRouter: Router {

    private weak var navigationController: UINavigationController?

    init(navigationController: UINavigationController?) {
        self.navigationController = navigationController
    }

    func navigate(to destination: GlobalPayModel.Path) {
        let viewController = makeViewController(for: destination)
        navigationController?.pushViewController(viewController, animated: true)
    }

    private func makeViewController(for destination: GlobalPayModel.Path) -> UIViewController {
        switch destination {
        case .accessToken:
            return AccessTokenBuilder.build()
        case .transactions:
            return TransactionsBuilder.build()
        case .verifications:
            return VerificationsBuilder.build()
        case .paymentMethods:
            return PaymentMethodsBuilder.build()
        case .deposits:
            return DepositsReportBuilder.build()
        case .disputes:
            return DisputesBuilder.build()
        case .authentications:
            return AuthenticationsBuilder.build()
        case .merchant:
            return MerchantBuilder.build()
        case .digitalWallets:
            return DigitalWalletsBuilder.build()
        case .ach:
            return AchBuilder.build()
        case .payByLink:
            return PayByLinkBuilder.build()
        case .paypal:
            return PaypalBuilder.build()
        case .buyNowPayLater:
            return BuyNowPayLaterBuilder.build()
        case .openBanking:
            return OpenBankingBuilder.build()
        case .hostedFields:
            return HostedFieldsBuilder.build()
        }
    }
}
