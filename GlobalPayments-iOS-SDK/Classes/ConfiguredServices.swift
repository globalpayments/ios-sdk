public class ConfiguredServices {

    private var secure3dProviders: [Secure3dVersion: Secure3dProvider]
    var gatewayConnector: PaymentGateway?
    var recurringConnector: RecurringService?
    var reportingService: ReportingService?

    public init() {
        self.secure3dProviders = [Secure3dVersion: Secure3dProvider]()
    }

    func getSecure3DProvider(version: Secure3dVersion) -> Secure3dProvider? {
        if secure3dProviders.keys.contains(version) {
            return secure3dProviders[version]
        } else if version == .any {
            var provider = secure3dProviders[.two]
            if provider == nil {
                provider = secure3dProviders[.one]
            }
            return provider
        }
        return nil
    }

    func setSecure3dProvider(provider: Secure3dProvider, version: Secure3dVersion) {
        secure3dProviders[version] = provider
    }
}
