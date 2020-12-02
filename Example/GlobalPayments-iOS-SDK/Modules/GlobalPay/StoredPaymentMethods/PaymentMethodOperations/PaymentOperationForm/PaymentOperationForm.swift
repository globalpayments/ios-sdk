import Foundation

struct PaymentOperationForm {
    let operationType: PaymentMethodOperationType
    let paymentMethodId: String
    let cardNumber: String
    let cardExpiryMonth: Int
    let cardExpiryYear: Int
    let cvn: String
}
