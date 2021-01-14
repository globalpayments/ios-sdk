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
    let stage: DisputeStage?
    let fromStageTimeCreated: Date?
    let toStageTimeCreated: Date?
    let adjustmentFunding: AdjustmentFunding?
    let fromAdjustmentTimeCreated: Date?
    let toAdjustmentTimeCreated: Date?
    let systemMID: String?
    let systemHierarchy: String?
    let source: Source

    enum Source {
        case settlement
        case regular
    }
}
