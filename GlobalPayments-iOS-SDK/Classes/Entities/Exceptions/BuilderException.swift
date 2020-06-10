import Foundation

@objcMembers public class BuilderException: NSError {

    private static let domain: String = "com.globalpayments.builder.exception"

    public static let code: Int = 2000

    public static func generic(message: String?) -> NSError {
        return NSError(domain: domain, code: code, userInfo: [
            NSLocalizedDescriptionKey: message ?? .empty
            ]
        )
    }
}

