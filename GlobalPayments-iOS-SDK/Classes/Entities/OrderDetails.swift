import Foundation

public class Tax: Codable {
    public var type: String
    public var amount: String
    public var percentage: String?

    public init(type: String, amount: String, percentage: String? = nil) {
        self.type = type
        self.amount = amount
        self.percentage = percentage
    }
}

public class OrderDetails: NSObject {
    
    public var shippingAmount: NSDecimalNumber?
    public var dutyAmount: NSDecimalNumber?
    public var insuranceAmount: NSDecimalNumber?
    public var hasInsurance: Bool?
    public var handlingAmount: NSDecimalNumber?
    public var orderDescription: String?
    public var taxes: [Tax] = []
    public var localTaxPercentage: String?
    public var buyerRecipientName: String?
    public var stateTaxIdReference: String?
    public var merchantTaxIdReference: String?
    
    public override init() { }
}
