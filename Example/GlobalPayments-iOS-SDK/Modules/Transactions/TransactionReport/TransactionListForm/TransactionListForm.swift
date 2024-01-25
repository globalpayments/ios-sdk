import Foundation
import GlobalPayments_iOS_SDK

struct TransactionListForm {
    var page: Int = 0
    var pageSize: Int = 0
    var sortProperty: TransactionSortProperty?
    var sortOrder: SortDirection?
    var transactionId: String?
    var type: PaymentType?
    var channel: Channel?
    var amount: NSDecimalNumber? = 0.0
    var currency: String? = ""
    var numberFirst6: String? = ""
    var numberLast4: String? = ""
    var tokenFirst6: String? = ""
    var tokenLast4: String? = ""
    var accountName: String? = ""
    var name: String? = ""
    var cardBrand: String? = ""
    var brandReference: String? = ""
    var authCode: String? = ""
    var referenceNumber: String? = ""
    var transactionStatus: TransactionStatus?
    var startDate: Date? = Date()
    var endDate: Date? = Date()
    var country: String? = ""
    var batchId: String? = ""
    var entryMode: PaymentEntryMode?
    var source: Source? = .regular

    enum Source {
        case settlement
        case regular
    }
}
