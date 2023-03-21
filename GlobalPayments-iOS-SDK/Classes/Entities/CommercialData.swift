import Foundation

public class CommercialData {
    public var additionalTaxDetails: AdditionalTaxDetails?
    public var commercialIndicator: CommercialIndicator
    public var customerVATNumber: String?
    public var customerReferenceId: String?
    public var description: String?
    public var discountAmount: NSDecimalNumber?
    public var dutyAmount: NSDecimalNumber?
    public var destinationPostalCode: String?
    public var destinationCountryCode: String?
    public var freightAmount: NSDecimalNumber?
    public var lineItems: [CommercialLineItem]
    public var orderDate: Date?
    public var originPostalCode: String?
    public var poNumber: String?
    public var supplierReferenceNumber: String?
    public var summaryCommodityCode: String?
    public var taxAmount: NSDecimalNumber?
    public var taxType: TaxType
    public var vatInvoiceNumber: String?

    public init(taxType: TaxType, commercialIndicator: CommercialIndicator = .level_III) {
        self.taxType = taxType
        self.commercialIndicator = commercialIndicator
        self.lineItems = [CommercialLineItem]()
    }

    public func addLineItems(_ items: [CommercialLineItem]) -> CommercialData {
        lineItems += items
        return self
    }
}
