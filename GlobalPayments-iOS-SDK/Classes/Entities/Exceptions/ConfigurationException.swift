import Foundation

@objcMembers public class ConfigurationException: NSError {

    private static let domain: String = "com.globalpayments.configuration.exception"

    public static let code: Int = 3000

    public static func generic(message: String?) -> NSError {
        return NSError(domain: domain, code: code, userInfo: [
            NSLocalizedDescriptionKey: message ?? .empty
            ]
        )
    }
}
