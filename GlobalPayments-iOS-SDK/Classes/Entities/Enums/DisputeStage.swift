import Foundation

public enum DisputeStage: String, Mappable, CaseIterable {
    case retrieval = "RETRIEVAL"
    case chargeback = "CHARGEBACK"
    case reversal = "REVERSAL"
    case secondChargeback = "SECOND_CHARGEBACK"
    case preArbitration = "PRE_ARBITRATION"
    case arbitration = "ARBITRATION"
    case preCompliance = "PRE_COMPLIANCE"
    case compliance = "COMPLIANCE"
    case goodFaith = "GOODFAITH"
    case mastercardPreDispute = "MASTERCARD PRE-DISPUTE"

    public init?(value: String?) {
        guard let value = value else { return nil }
        // The GP-API returns "GOOD_FAITH" in responses while the specification documents "GOODFAITH".
        if value == "GOOD_FAITH" {
            self = .goodFaith
            return
        }
        guard let stage = DisputeStage(rawValue: value) else { return nil }
        self = stage
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
