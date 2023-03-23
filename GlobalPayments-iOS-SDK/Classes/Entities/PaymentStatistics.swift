import Foundation

public class PaymentStatistics: NSObject {
    /// The total monthly sales of the merchant.
    public var totalMonthlySalesAmount: NSDecimalNumber?
    /// The total monthly sales of the merchant.
    public var averageTicketSalesAmount: NSDecimalNumber?
    /// The merchants highest ticket amount.
    public var highestTicketSalesAmount: NSDecimalNumber?
}
