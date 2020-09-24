import Foundation

public enum DisputeSortProperty: String, Mappable {
    case id = "id"
    case arn = "arn"
    case brand = "brand"
    case status = "status"
    case stage = "stage"
    case fromStageTimeCreated = "from_stage_time_created"
    case toStageTimeCreated = "to_stage_time_created"
    case adjustmentFunding = "adjustment_funding"
    case fromAdjustmentTimeCreated = "from_adjustment_time_created"
    case toAdjustmentTimeCreated = "to_adjustment_time_created"

    public func mapped(for target: Target) -> String? {
        switch target {
        case .gpApi:
            return self.rawValue
        default:
            return nil
        }
    }
}
