import Foundation

public enum DocumentType: String, Mappable, Encodable {
    case salesReceipt = "SALES_RECEIPT"
    case proofOfDelivery = "PROOF_OF_DELIVERY"
    case refundPolicy = "REFUND_POLICY"
    case termsAndConditions = "TERMS_AND_CONDITIONS"
    case cancelationPolicy = "CANCELLATION_POLICY"
    case other = "OTHER"

    public init?(value: String?) {
        guard let value = value,
              let type = DocumentType(rawValue: value) else { return nil }
        self = type
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
