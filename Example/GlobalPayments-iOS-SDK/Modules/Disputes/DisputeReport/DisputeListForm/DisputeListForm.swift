import Foundation
import GlobalPayments_iOS_SDK

struct DisputeListForm {
    let page: Int
    let pageSize: Int
    let sortProperty: DisputeSortProperty
    let sordOrder: SortDirection
    let arn: String?
    let brand: String?
    let status: DisputeStatus?
    let stage: DisputeStage
    let fromStageTimeCreated: Date?
    let toStageTimeCreated: Date?
    let systemMID: String?
    let systemHierarchy: String?
    let disputeId: String?
    let fromTimeCreated: Date?
    let toTimeCreated: Date?
    let source: Source

    enum Source {
        case settlement
        case regular
    }
}
