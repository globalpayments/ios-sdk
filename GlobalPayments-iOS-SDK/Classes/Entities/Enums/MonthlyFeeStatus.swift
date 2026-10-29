import Foundation

public enum MonthlyFeeStatus: String, Mappable, CaseIterable {
    case finalized = "FINALIZED"
    case estimated = "ESTIMATED"

    public init?(value: String?) {
        guard let value = value,
              let status = MonthlyFeeStatus(rawValue: value) else { return nil }
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
