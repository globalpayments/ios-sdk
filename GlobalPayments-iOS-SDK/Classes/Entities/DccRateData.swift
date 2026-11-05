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
    public var timeCreated: Date?
    public var model: String?
    public var status: String?
    public var country: String?
    public var minorUnits: String?
    public var formattedAmount: String?
    public var payerRegion: String?
    public var merchantId: String?
    public var merchantName: String?
    public var accountId: String?
    public var accountName: String?
    public var reference: String?
    public var paymentMethodResult: String?
    public var paymentMethodMessage: String?
    public var paymentMethodEntryMode: String?
    public var maskedCardNumberLast4: String?
    public var cardBrand: String?
    public var action: ActionSummary?

    public func normalizedRateType() -> DccRateType {
        return dccRateType == .refund ? .refund : .sale
    }
}
