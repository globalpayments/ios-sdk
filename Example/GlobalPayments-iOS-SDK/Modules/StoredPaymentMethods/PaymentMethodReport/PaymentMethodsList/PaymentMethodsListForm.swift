import Foundation
import GlobalPayments_iOS_SDK

struct PaymentMethodsListForm {
    var page: Int? = 0
    var pageSize: Int? = 0
    var orderBy: DepositSortProperty?
    var order: SortDirection?
    var accountName: String? = ""
    var id: String? = ""
    var status: StoredPaymentMethodStatus?
    var fromTimeCreated: Date? = Date()
    var toTimeCreated: Date? = Date()
    var startLastUpdatedDate: Date? = Date()
    var endLastUpdatedDate: Date? = Date()
    var referenceNumber: String? = ""
    var amount: NSDecimalNumber? = 0.0
}
