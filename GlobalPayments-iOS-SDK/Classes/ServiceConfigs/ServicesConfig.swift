import Foundation

/// Configuration for connecting to a payment gateway
public class ServiceConfig {
    /// Connection details for your processing gateway
    public var gatewayConfig: GatewayConfig?

    public var timeout: Int = .zero {
        didSet(newValue) {
            gatewayConfig?.timeout = newValue
        }
    }

    func validate() {
        gatewayConfig?.validate()
    }
}
