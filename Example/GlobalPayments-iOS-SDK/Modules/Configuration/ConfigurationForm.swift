import Foundation
import GlobalPayments_iOS_SDK

struct ConfigurationForm {
    var appId: String?
    var appKey: String?
    var secondsToExpire: Int?
    var intervalToExpire: IntervalToExpire?
    var channel: Channel?
    var language: Language?
    var country: String?
    var challengeNotificationUrl: String?
    var methodNotificationUrl: String?
    var merchantContactUrl: String?
    var statusUrl: String?
    var merchantId: String?
    var transactionProcessing: String?
    var tokenization: String?
    var processingAccountId: String?
}
