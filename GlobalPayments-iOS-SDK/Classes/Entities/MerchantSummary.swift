import Foundation

public class MerchantSummary {
    /// A unique identifier for the object created by Global Payments. The first 3 characters identifies the resource an id relates to.
    public var id: String?
    /// The label to identify the merchant
    public var name: String?
    public var status: UserStatus?
}
