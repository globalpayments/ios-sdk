import Foundation

@objcMembers public class UnsupportedTransactionException: NSError {

    private static let domain: String = "com.globalpayments.transaction.exception"

    public static let code: Int = 4000

    public static func generic(message: String?) -> NSError {
        return NSError(domain: domain, code: code, userInfo: [
            NSLocalizedDescriptionKey: message ?? .empty
            ]
        )
    }
}
