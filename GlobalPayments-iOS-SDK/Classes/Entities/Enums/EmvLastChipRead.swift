import Foundation

public enum EmvLastChipRead: Mappable {
    case successful
    case failed
    case notAChipTransaction
    case unknown

    public init(rawValue: String) {
        switch rawValue {
        case "SUCCESSFUL", "CHIP_FAILED_PREV_SUCCESS", "PREV_SUCCESS":
            self = .successful
        case "FAILED", "CHIP_FAILED_PREV_FAILED", "PREV_FAILED":
            self = .failed
        case "NOT_A_CHIP_TRANSACTION":
            self = .notAChipTransaction
        case "UNKNOWN":
            self = .unknown
        default:
            self = .unknown
        }
    }

    public func mapped(for target: Target) -> String? {
        switch target {
        case .transit:
            switch self {
            case .successful:
                return "SUCCESSFUL"
            case .failed:
                return "FAILED"
            case .notAChipTransaction:
                return "NOT_A_CHIP_TRANSACTION"
            case .unknown:
                return "UNKNOWN"
            }
        case .portico:
            switch self {
            case .successful:
                return "CHIP_FAILED_PREV_SUCCESS"
            case .failed:
                return "CHIP_FAILED_PREV_FAILED"
            default:
                return nil
            }
        case .gpApi:
            switch self {
            case .successful:
                return "PREV_SUCCESS"
            case .failed:
                return "PREV_FAILED"
            default:
                return nil
            }
        default:
            return nil
        }
    }
}
