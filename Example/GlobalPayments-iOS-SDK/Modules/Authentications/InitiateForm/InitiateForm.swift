import Foundation
import GlobalPayments_iOS_SDK

struct InitiateForm {
    let card: CreditCardData
    let amount: NSDecimalNumber
    let currency: String
    let mehodCompletion: MethodUrlCompletion
    let authSource: AuthenticationSource
    let createDate: Date?
    let shippingAddress: Address
    let billingAddress: Address
    let browserData: BrowserData
}
