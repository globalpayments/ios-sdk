import Foundation

public enum AdjustmentFunding: String, Mappable {
    case credit = "CREDIT"
    case debit = "DEBIT"

    public func mapped(for target: Target) -> String? {
        switch target {
        case .gpApi:
            return self.rawValue
        default:
            return nil
        }
    }
}
