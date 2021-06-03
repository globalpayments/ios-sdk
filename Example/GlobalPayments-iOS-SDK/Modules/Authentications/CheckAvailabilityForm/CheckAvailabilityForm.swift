import Foundation
import GlobalPayments_iOS_SDK

struct CheckAvailabilityForm {
    let card: CreditCardData
    let amount: NSDecimalNumber
    let currency: String
}
