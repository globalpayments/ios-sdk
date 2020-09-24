import Foundation

public enum DepositSortProperty: String, Mappable {
    case timeCreated = "TIME_CREATED"
    case status = "STATUS"
    case type = "TYPE"
    case depositId = "DEPOSIT_ID"

    public func mapped(for target: Target) -> String? {
        switch target {
        case .gpApi:
            return self.rawValue
        default:
            return nil
        }
    }
}
