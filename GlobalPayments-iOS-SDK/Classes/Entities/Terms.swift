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
}
