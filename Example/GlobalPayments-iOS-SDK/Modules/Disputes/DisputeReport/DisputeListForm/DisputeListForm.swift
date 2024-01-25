import Foundation
import GlobalPayments_iOS_SDK

struct DisputeListForm {
    var page: Int = 0
    var pageSize: Int = 0
    var sortProperty: DisputeSortProperty?
    var sortOrder: SortDirection?
    var arn: String? = ""
    var brand: String? = ""
    var status: DisputeStatus?
    var stage: DisputeStage?
    var fromStageTimeCreated: Date? = Date()
    var toStageTimeCreated: Date? = Date()
    var systemMID: String? = ""
    var systemHierarchy: String? = ""
    var disputeId: String? = ""
    var fromTimeCreated: Date? = Date()
    var toTimeCreated: Date? = Date()
    var source: Source = .regular

    enum Source {
        case settlement
        case regular
    }
}
