import Foundation
import GlobalPayments_iOS_SDK

struct TransactionListForm {
    let page: Int
    let pageSize: Int
    let sortProperty: TransactionSortProperty
    let sordOrder: SortDirection
    let transactionId: String?
    let type: PaymentType?
    let channel: Channel?
    let amount: NSDecimalNumber?
    let currency: String?
    let numberFirst6: String?
    let numberLast4: String?
    let tokenFirst6: String?
    let tokenLast4: String?
    let accountName: String?
    let cardBrand: String?
    let brandReference: String?
    let authCode: String?
    let referenceNumber: String?
    let transactionStatus: TransactionStatus?
    let startDate: Date?
    let endDate: Date?
    let country: String?
    let batchId: String?
    let entryMode: PaymentEntryMode?
}
