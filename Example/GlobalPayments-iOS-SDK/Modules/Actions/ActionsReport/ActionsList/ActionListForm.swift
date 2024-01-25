import Foundation
import GlobalPayments_iOS_SDK

struct ActionListForm {
    var page: Int? = 0
    var pageSize: Int? = 0
    var orderBy: ActionSortProperty?
    var order: SortDirection?
    var id: String? = ""
    var fromTimeCreated: Date? = Date()
    var toTimeCreated: Date? = Date()
    var type: String? = ""
    var resource: String? = ""
    var resourceStatus: String? = ""
    var resourceId: String? = ""
    var merchantName: String? = ""
    var accountName: String? = ""
    var responseCode: String? = ""
    var httpResponseCode: String? = ""
    var appName: String? = ""
    var version: String? = ""
}
