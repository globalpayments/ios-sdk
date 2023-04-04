import Foundation

protocol GpApiRequestData {
    associatedtype Builder
    associatedtype Config
    associatedtype Payload

    func initBaseParams(payload: inout JsonDoc, config: GpApiConfig?)
    func generateRequest(for builder: Builder, config: Config) -> Payload
}

extension GpApiRequestData {

    func initBaseParams(payload: inout JsonDoc, config: GpApiConfig?) {
        payload
            .set(for: "account_name", value: config?.accessTokenInfo?.transactionProcessingAccountName)
            .set(for: "account_id", value: config?.accessTokenInfo?.transactionProcessingAccountID)
            .set(for: "channel", value: config?.channel.mapped(for: .gpApi))
            .set(for: "country", value: config?.country)
    }
}
