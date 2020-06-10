import Foundation

@objcMembers public class ApiException: NSError {

    private static let domain: String = "com.globalpayments.api.exception"

    public static let code: Int = 1000

    public static func generic(message: String) -> NSError {
        return NSError(domain: domain, code: code, userInfo: [
            NSLocalizedDescriptionKey: message
            ]
        )
    }
}
