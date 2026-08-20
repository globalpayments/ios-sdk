import Foundation

/// Represents a single APM provider configuration block used in the HPP /links `payment_method_configuration.apm.configurations` array.
///
/// Example (Cashpresso):
/// ```json
/// { "provider": "CASHPRESSO", "payment_plans": ["PAY_IN_3_INSTALLMENTS", "PAY_30_DAYS"] }
/// ```
public class ApmProviderConfiguration: NSObject {

    /// The APM provider identifier (e.g. `AlternativePaymentMethodType.CASHPRESSO`).
    public var provider: AlternativePaymentMethodType?

    /// The payment plans offered for this APM provider (Cashpresso-specific).
    public var paymentPlans: [CashpressoPaymentPlan]?

    public init(provider: AlternativePaymentMethodType, paymentPlans: [CashpressoPaymentPlan]? = nil) {
        self.provider = provider
        self.paymentPlans = paymentPlans
    }
}
