import Foundation

@objcMembers public class ServiceConfig: NSObject {
    // Portico
    public var siteId: String?
    public var licenceId: String?
    public var deviceId: String?
    public var username: String?
    public var password: String?
    public var developerId: String?
    public var versionNumber: String?
    public var secretApiKey: String?

    // Realex (GP-ECOM)
    public var accountId: String?
    public var merchantId: String?
    public var sharedSecret: String?
    public var rebatePassword: String?
    public var refundPassword: String?
    public var channel: String?
    public var hostedPaymentConfig: HostedPaymentConfig?

    public var challengeNotificationUrl: String?
    public var merchantContactUrl: String?
    public var methodNotificationUrl: String?
    public var secure3dVersion: Secure3dVersion?
    public var curlOptions: [Int: String]?

    // Environment
    public var environment: Environment?
    public var serviceUrl: String?
    public var timeout: Int?

    public override required init() {
        self.timeout = 65000
        self.environment = .test
    }

    public func validate() throws {

        // Portico API key
        if !secretApiKey.isNilOrEmpty
            && (!siteId.isNilOrEmpty
                || !licenceId.isNilOrEmpty
                || !deviceId.isNilOrEmpty
                || !username.isNilOrEmpty
                || !password.isNilOrEmpty) {
            throw ConfigurationException.generic(message: "Configuration contains both secret API key and legacy credentials. These are mutually exclusive.")
        }

        // Portico legacy
        if (!siteId.isNilOrEmpty
            || !licenceId.isNilOrEmpty
            || !deviceId.isNilOrEmpty
            || !username.isNilOrEmpty
            || !password.isNilOrEmpty)
            &&
            (siteId.isNilOrEmpty
                || licenceId.isNilOrEmpty
                || deviceId.isNilOrEmpty
                || username.isNilOrEmpty
                || password.isNilOrEmpty) {
            throw ConfigurationException.generic(message: "Site, License, Device, Username, and Password should all have values for this configuration.")
        }

        // Realex
        if (secretApiKey.isNilOrEmpty
            && (siteId.isNilOrEmpty
                && licenceId.isNilOrEmpty
                && deviceId.isNilOrEmpty
                && username.isNilOrEmpty
                && password.isNilOrEmpty))
            && merchantId.isNilOrEmpty {
            throw ConfigurationException.generic(message: "MerchantId should not be empty for this configuration.")
        }

        // Service URL
        if serviceUrl.isNilOrEmpty && secure3dVersion == nil {
            throw ConfigurationException.generic(message: "Service URL could not be determined from the credentials provided. Please specify an endpoint.")
        }

        // Secure 3D
        if secure3dVersion != nil {
            if secure3dVersion == .two || secure3dVersion == .any {
                if challengeNotificationUrl.isNilOrEmpty {
                    throw ConfigurationException.generic(message: "The challenge notification URL is required for 3DS v2 processing.")
                }
                if methodNotificationUrl.isNilOrEmpty {
                    throw ConfigurationException.generic(message: "The method notification URL is required for 3DS v2 processing.")
                }
            }
        }
    }
}
