import Foundation

public enum MerchantDocumentCategory: String, Mappable, CaseIterable {
    
    case identity_verification
    case risk_review
    case underwriting
    case verification
    
    public init?(value: String?) {
        guard let value = value,
              let category = MerchantDocumentCategory(rawValue: value) else { return nil }
        self = category
    }
    
    public func mapped(for target: Target) -> String? {
        switch target {
        case .gpApi:
            return self.rawValue.uppercased()
        default:
            return nil
        }
    }
}
