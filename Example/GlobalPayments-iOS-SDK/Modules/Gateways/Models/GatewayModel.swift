import Foundation

struct GatewayModel {
    let name: String
    let identifier: Gateway

    enum Gateway {
        case gpapi
        case portico
        case realex
    }
}

extension GatewayModel {

    static var models: [GatewayModel] {
        [
            GatewayModel(name: "gateways.gpapi.title".localized(), identifier: .gpapi),
            GatewayModel(name: "gateways.portico.title".localized(), identifier: .portico),
            GatewayModel(name: "gateways.realex.title".localized(), identifier: .realex)
        ]
    }
}
