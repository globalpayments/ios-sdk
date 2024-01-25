import Foundation
import GlobalPayments_iOS_SDK

struct DepositsListForm {
    var page: Int? = 0
    var pageSize: Int? = 0
    var orderBy: DepositSortProperty?
    var order: SortDirection?
    var accountName: String? = ""
    var id: String? = ""
    var status: DepositStatus?
    var fromTimeCreated: Date? = Date()
    var toTimeCreated: Date? = Date()
    var amount: NSDecimalNumber? = 0.0
    var maskedNumber: String? = ""
    var systemMID: String? = ""
    var systemHierarchy: String? = ""
}
