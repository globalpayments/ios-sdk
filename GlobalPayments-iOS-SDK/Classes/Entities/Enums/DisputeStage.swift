import Foundation

public enum DisputeStage: String, Mappable {
    case retrieval = "RETRIEVAL"
    case chargeback = "CHARGEBACK"
    case reversal = "REVERSAL"
    case secondChargeback = "SECOND_CHARGEBACK"
    case preArbitration = "PRE_ARBITRATION"
    case arbitration = "ARBITRATION"
    case preCompliance = "PRE_COMPLIANCE"
    case compliance = "Compliance"
    case goodFaith = "GOODFAITH"

    public func mapped(for target: Target) -> String? {
        switch target {
        case .gpApi:
            return self.rawValue
        default:
            return nil
        }
    }
}
