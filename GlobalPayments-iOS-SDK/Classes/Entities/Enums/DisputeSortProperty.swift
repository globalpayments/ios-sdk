import Foundation

public enum DisputeSortProperty: String, Mappable, CaseIterable {
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

    public init?(value: String?) {
        guard let value = value,
              let sort = DisputeSortProperty(rawValue: value) else { return nil }
        self = sort
    }

    public func mapped(for target: Target) -> String? {
        switch target {
        case .gpApi:
            return self.rawValue
        default:
            return nil
        }
    }
}
