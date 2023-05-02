import Foundation
import GlobalPayments_iOS_SDK

struct PayLinkForm {
    let usageMode: String
    let usageLimit: String
    let name: String
    let amount: NSDecimalNumber
    let expirationDate: String
}
