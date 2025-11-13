import Foundation

internal protocol IRequestBuilder {
    associatedtype BuilderType
    func buildRequest(builder: BuilderType, gateway: GpApiConnector) -> GpApiRequest?
}
