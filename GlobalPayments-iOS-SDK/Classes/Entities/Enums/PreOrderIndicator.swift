import Foundation

public enum PreOrderIndicator: Mappable {
    case merchandiseAvailable
    case futureAvailablity
    case firstTimeOrder
    case reorder

    public init?(value: String?) {
        guard let value = value else { return nil }
        switch value {
        case "FIRST_TIME_ORDER":
            self = .firstTimeOrder
        case "REORDER":
            self = .reorder
        default:
            return nil
        }
    }

    public func mapped(for target: Target) -> String? {
        switch target {
        case .gpApi:
            switch self {
            case .firstTimeOrder:
                return "FIRST_TIME_ORDER"
            case .reorder:
                return "REORDER"
            default:
                return nil
            }
        default:
            return nil
        }
    }
}
