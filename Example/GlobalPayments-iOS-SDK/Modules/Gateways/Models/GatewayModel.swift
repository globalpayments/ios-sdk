import Foundation

struct GatewayModel {
    let name: String
    let implented: Bool
}

extension GatewayModel {

    static var models: [GatewayModel] {
        [
            GatewayModel(name: "gateways.gpapi.title".localized(),   implented: true),
            GatewayModel(name: "gateways.portico.title".localized(), implented: false),
            GatewayModel(name: "gateways.realex.title".localized(),  implented: false)
        ]
    }
}
