import Foundation

public enum DepositStatus: String, Mappable {
    case funded = "FUNDED"
    case splitFunding = "SPLIT_FUNDING"
    case delayed = "DELAYED"
    case reversed = "RESERVED"
    case irreg = "IRREG"
    case released = "RELEASED"

    public init?(value: String?) {
        guard let value = value,
              let status = DepositStatus(rawValue: value) else { return nil }
        self = status
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
