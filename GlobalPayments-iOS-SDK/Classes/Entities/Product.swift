import Foundation

public class Product: NSObject {
    public var productId: String?
    public var productName: String?
    public var descriptionProduct: String?
    public var quantity: Int?
    public var unitPrice: NSDecimalNumber?
    public var netUnitPrice: NSDecimalNumber?
    public var gift: Bool?
    public var unitCurrency: String?
    public var type: String?
    public var risk: String?
    public var taxAmount: NSDecimalNumber?
    public var taxPercentage: NSDecimalNumber?
    public var discountAmount: NSDecimalNumber?
    public var url: String?
    public var imageUrl: String?
    public var netUnitAmount: NSDecimalNumber?
    public var giftCardCurrency: String?
}
