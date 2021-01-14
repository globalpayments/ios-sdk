import Foundation

public enum AdjustmentFunding: String, Mappable, CaseIterable {
    case credit = "CREDIT"
    case debit = "DEBIT"

    public init?(value: String?) {
        guard let value = value,
              let funding = AdjustmentFunding(rawValue: value) else { return nil }
        self = funding
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
