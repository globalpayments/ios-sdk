import Foundation

public enum ExemptStatus: String {
    case lowValue = "LOW_VALUE"
    case transactionRiskAnalysis = "TRANSACTION_RISK_ANALYSIS"
    case trustedMerchant = "TRUSTED_MERCHANT"
    case secureCorporatePayment = "SECURE_CORPORATE_PAYMENT"
    case scaDelegation = "SCA_DELEGATION"
}
