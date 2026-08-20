import Foundation

/// Cashpresso payment plan options for both direct API (/transactions) and HPP (/links) flows.
public enum CashpressoPaymentPlan: String, Mappable, CaseIterable {

    case PAY_IN_3_INSTALLMENTS
    case PAY_30_DAYS

    public init?(value: String?) {
        guard let value = value,
              let plan = CashpressoPaymentPlan(rawValue: value) else { return nil }
        self = plan
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
