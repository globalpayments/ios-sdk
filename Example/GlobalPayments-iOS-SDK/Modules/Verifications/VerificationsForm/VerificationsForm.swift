import Foundation
import GlobalPayments_iOS_SDK

struct VerificationsForm {
    let reference: String?
    let currency: String
    let country: String?
    let id: String?
    let firstName: String?
    let lastName: String?
    let cardNumber: String
    let expiryMonth: Int
    let expiryYear: Int
    let cvn: String
    let avsAddress: String?
    let avsPostalCode: String?
    let idempotencyKey: String?
}
