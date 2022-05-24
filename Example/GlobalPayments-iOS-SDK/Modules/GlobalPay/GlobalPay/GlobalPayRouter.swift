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
            return DepositsBuilder.build()
        case .disputes:
            return DisputesBuilder.build()
        case .authentications:
            return AuthenticationsBuilder.build()
        case .digitalWallets:
            return DigitalWalletsBuilder.build()
        }
    }
}
