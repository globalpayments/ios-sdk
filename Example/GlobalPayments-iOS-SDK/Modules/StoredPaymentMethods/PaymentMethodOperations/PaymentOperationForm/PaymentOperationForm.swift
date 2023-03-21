import Foundation
import GlobalPayments_iOS_SDK

struct PaymentOperationForm {
    let operationType: PaymentMethodOperationType
    let methodUsageMode: PaymentMethodUsageMode?
    let paymentMethodId: String
    let cardNumber: String
    let cardExpiryMonth: Int
    let cardExpiryYear: Int
    let cvn: String
}
