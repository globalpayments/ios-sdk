import Foundation
import GlobalPayments_iOS_SDK

struct TransactionListForm {
    let sortProperty: TransactionSortProperty
    let sordOrder: SortDirection
    let page: Int
    let pageSize: Int
    let transactionId: String?
    let accountName: String?
    let cardBrand: String?
    let maskedCardNumber: String?
    let arn: String?
    let brandReference: String?
    let authCode: String?
    let referenceNumber: String?
    let transactionStatus: TransactionStatus?
    let startDate: Date?
    let endDate: Date?
    let depositReference: String?
    let startDepositDate: Date?
    let endDepositDate: Date?
    let startBatchDate: Date?
    let endBatchDate: Date?
    let merchantId: String?
    let systemHierarchy: String?
}
