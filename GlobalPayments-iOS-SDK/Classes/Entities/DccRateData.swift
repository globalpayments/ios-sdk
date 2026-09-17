import Foundation

public class DccRateData: NSObject {
    public var cardHolderAmount: NSDecimalNumber?
    public var cardHolderCurrency: String?
    public var cardHolderRate: NSDecimalNumber?
    public var commissionPercentage: String?
    public var dccProcessor: DccProcessor?
    public var dccRateType: DccRateType?
    public var exchangeRateSourceName: String?
    public var exchangeRateSourceTimestamp: Date?
    public var merchantAmount: NSDecimalNumber?
    public var merchantCurrency: String?
    public var marginRatePercentage: String?
    public var dccId: String?
    public var orderId: String?
    public var conversionRate: String?
    public var exchangeSourceTime: String?

    public func normalizedRateType() -> DccRateType {
        return dccRateType == .refund ? .refund : .sale
    }
}
