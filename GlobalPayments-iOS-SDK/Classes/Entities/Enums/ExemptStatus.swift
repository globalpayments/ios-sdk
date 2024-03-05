import Foundation

public enum ExemptStatus: String, CaseIterable {
    case lowValue = "LOW_VALUE"
    case transactionRiskAnalysis = "TRANSACTION_RISK_ANALYSIS"
    case trustedMerchant = "TRUSTED_MERCHANT"
    case secureCorporatePayment = "SECURE_CORPORATE_PAYMENT"
    case scaDelegation = "SCA_DELEGATION"
    
    public init?(value: String?) {
        guard let value = value,
              let status = ExemptStatus(rawValue: value) else { return nil }
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
