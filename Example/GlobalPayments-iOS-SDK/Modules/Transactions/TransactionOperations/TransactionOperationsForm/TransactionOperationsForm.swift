import Foundation
import GlobalPayments_iOS_SDK

struct TransactionOperationsForm {
    let cardNumber: String
    let expiryMonth: Int
    let expiryYear: Int
    let cvv: String
    let amount: NSDecimalNumber
    let currency: String
    let transactionOperationType: TransactionOperationType
    let idempotencyKey: String?
    let manualEntryMethod: ManualEntryMethod?
}
