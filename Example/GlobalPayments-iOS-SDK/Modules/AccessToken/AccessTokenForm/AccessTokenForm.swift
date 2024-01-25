import Foundation
import GlobalPayments_iOS_SDK

struct AccessTokenForm {
    let appId: String
    let appKey: String
    let secondsToExpire: Int?
    let environment: Environment
    let interval: IntervalToExpire
    var permissions: [String]
}
