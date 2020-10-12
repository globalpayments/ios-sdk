import Foundation

public class DisputeAction {
    /// Unique identifier for the Dispute on the Global Payments system.
    public var reference: String?
    /// Describes where the Dispute is in its' lifecycle.
    public var status: DisputeStatus?
    /// Describes where the Dispute is in its' lifecycle.
    public var stage: DisputeStage?
    /// The amount the merchant is currently liable for the dispute.
    public var amount: NSDecimalNumber?
    /// The currency of the amount. This is in the currency the merchant is affected in.
    public var currency: String?
    public var reasonCode: String?
    public var reasonDescription: String?
    /// Indicates the result of the Dispute.
    public var result: DisputeResult?
    /// A list of evidence provided by the Merchant that relate to the Dispute.
    public var documents: [String]?
}
