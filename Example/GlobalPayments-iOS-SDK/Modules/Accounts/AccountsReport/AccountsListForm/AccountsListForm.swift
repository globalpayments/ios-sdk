import Foundation
import GlobalPayments_iOS_SDK

struct AccountsListForm {
    var page: Int? = 0
    var pageSize: Int? = 0
    var orderBy: TransactionSortProperty?
    var order: SortDirection?
    var id: String? = ""
    var fromTimeCreated: Date? = Date()
    var toTimeCreated: Date? = Date()
    var name: String? = ""
    var status: UserStatus?
}
