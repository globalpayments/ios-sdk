import Foundation

struct GlobalPayModel {
    let name: String
    let path: Path

    enum Path {
        case accessToken
        case transactions
        case verifications
        case paymentMethods
        case deposits
        case disputes
        case authentications
        case digitalWallets
        case ach
    }
}

extension GlobalPayModel {

    static var models: [GlobalPayModel] {
        [
            GlobalPayModel(name: "globalpay.access.token.title".localized(), path: .accessToken),
            GlobalPayModel(name: "globalpay.transactions.title".localized(), path: .transactions),
            GlobalPayModel(name: "globalpay.verifications.title".localized(), path: .verifications),
            GlobalPayModel(name: "globalpay.payment.methods.title".localized(), path: .paymentMethods),
            GlobalPayModel(name: "globalpay.deposits.title".localized(), path: .deposits),
            GlobalPayModel(name: "globalpay.disputes.title".localized(), path: .disputes),
            GlobalPayModel(name: "globalpay.disputes.authentications".localized(), path: .authentications),
            GlobalPayModel(name: "globalpay.digital.wallets".localized(), path: .digitalWallets),
            GlobalPayModel(name: "globalpay.ach".localized(), path: .ach)
        ]
    }
}
