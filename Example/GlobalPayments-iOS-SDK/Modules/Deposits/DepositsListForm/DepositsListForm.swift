import Foundation
import GlobalPayments_iOS_SDK

struct DepositsListForm {
    let page: Int
    let pageSize: Int
    let orderBy: DepositSortProperty
    let order: SortDirection
    let accountName: String?
    let fromTimeCreated: Date?
    let id: String?
    let status: DepositStatus?
    let toTimeCreated: Date?
    let amount: NSDecimalNumber?
    let maskedNumber: String?
    let systemMID: String?
    let systemHierarchy: String?
}
