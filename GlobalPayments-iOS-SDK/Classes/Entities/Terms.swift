import Foundation

/// <summary>
/// Represents the terms result return by GP API
/// </summary>
public class Terms {
    /// <summary>
    /// Reprenents the reference to the installment option being offered.
    /// This field is applicable only if the installment.program is SIP.
    /// </summary>
    public var Id: String?
    /// <summary>
    /// Indicates if installment.term.time_unit_number is days, months or years
    /// </summary>
    public var TimeUnit: String?
    /// <summary>
    /// Indicates the total number of payments to be made over the course of the installment payment plan.
    /// </summary>
    public var timeUnitNumbers: [Int]?
    
    /// <summary>
    /// A unique identifier used to identify the installment plan.
    /// </summary>
    public var reference: String?
    
    /// <summary>
    /// Name of the Installment Plan.
    /// </summary>
    public var name: String?
    
    /// <summary>
    /// This is the type of Installment Plan.
    /// </summary>
    public var mode: String?
    
    /// <summary>
    /// Indicates the total number of payments to be made over the course of the installment payment plan.
    /// </summary>
    public var count: Int64?
    
    /// <summary>
    /// The grace period before the first payment. 00 indicates no grace period. This field is available to Mexico merchants only.
    /// </summary>
    public var gracePeriodCount: Int?

    /// <summary>
    /// The currency of the fees attached to the installment plan.
    /// </summary>
    public var currency: String?

    /// <summary>
    /// Annual percentage rate (APR) as configured by the Issuer during plan creation.
    /// </summary>
    public var costPercentage: String?

    /// <summary>
    /// The total cost of the installment plan inclusive of fees.
    /// </summary>
    public var totalPlanCost: String?

    /// <summary>
    /// The amount to be paid at each installment.
    /// </summary>
    public var planAmount: String?

    /// <summary>
    /// The terms and conditions to be displayed to the cardholder for this plan.
    /// </summary>
    public var termsAndConditions: [InstallmentTermsAndConditions]?

    /// <summary>
    /// The fees attached to the installment plan.
    /// </summary>
    public var fees: InstallmentFees?
}

/// <summary>
/// Represents the terms and conditions hosted by the Issuer for an installment plan.
/// </summary>
public class InstallmentTermsAndConditions {
    /// Terms and conditions URL hosted by the Issuer.
    public var url: String?
    /// Version of the terms and conditions displayed to the cardholder.
    public var version: String?
    /// Text of the terms and conditions for the installment plan.
    public var termsDescription: String?
    /// Language of the terms and conditions text, in ISO-639-1 (alpha-2) format.
    public var language: String?
}

/// <summary>
/// Represents an individual fee applied on an installment plan.
/// </summary>
public class InstallmentFeeInfo {
    /// Fee type, e.g. CONSUMER, CONSUMER_UPFRONT, MERCHANT_FUNDING, MERCHANT_SERVICE.
    public var type: String?
    /// Interest fee rate in percentage applied on the installment payment.
    public var interestRate: String?
    /// Flat fee applied on the first installment payment in Issuer currency.
    public var flatAmount: String?
}

/// <summary>
/// Represents the fees breakdown of an installment plan.
/// </summary>
public class InstallmentFees {
    /// Fee types with their associated cost percentage or flat fee.
    public var feeInfo: [InstallmentFeeInfo]?
    /// Total fees charged, calculated as total upfront fees + total recurring fees.
    public var totalAmount: String?
    /// Total recurring fees for this installment plan.
    public var totalSubsequentAmount: String?
    /// The consumer fee for every installment period, including the first one.
    public var subsequentAmount: String?
    /// Total upfront fees charged to the consumer for this installment plan.
    public var totalUpfrontAmount: String?
    /// Upfront fees charged to the consumer for this installment plan.
    public var upfrontAmount: String?
}

/// Create a Terms instance with optional fields.
/// This static factory is public so clients/tests can construct Terms even if
/// the type's initializer was marked internal in the original source.
public extension Terms {
    static func make(timeUnit: String? = nil, count: Int? = nil, mode: String? = nil) -> Terms {
        // Initialize using the default initializer available within the SDK module.
        let result = Terms()
        if let tu = timeUnit { result.TimeUnit = tu }
        if let c = count { result.count = Int64(c) }
        if let m = mode { result.mode = m }
        return result
    }
}
