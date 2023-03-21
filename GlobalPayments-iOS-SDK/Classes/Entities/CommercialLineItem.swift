import Foundation

public class CommercialLineItem {
    public var alternateTaxId: String?
    public var commodityCode: String?
    public var creditDebitIndicator: CreditDebitIndicator?
    public var description: String?
    public var discountDetails: DiscountDetails?
    public var extendedAmount: NSDecimalNumber?
    public var name: String?
    public var netGrossIndicator: NetGrossIndicator?
    public var productCode: String?
    public var quantity: NSDecimalNumber?
    public var unitCost: NSDecimalNumber?
    public var unitOfMeasure: String?
    public var upc: String?
    public var taxAmount: NSDecimalNumber?
    public var totalAmount: NSDecimalNumber?
}
