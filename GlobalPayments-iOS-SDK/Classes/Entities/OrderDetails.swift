import Foundation

public class Tax: Codable {
    public var type: String
    public var amount: String

    public init(type: String, amount: String) {
        self.type = type
        self.amount = amount
    }
}

public class OrderDetails: NSObject {
    
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
