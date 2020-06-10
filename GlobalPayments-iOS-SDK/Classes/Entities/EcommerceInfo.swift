import Foundation

/// Identifies eCommerce vs mail order / telephone order (MOTO) transactions.
@objc public enum EcommerceChannel: Int {
    /// Identifies eCommerce transactions.
    case ecom
    /// Identifies mail order / telephone order (MOTO) transactions.
    case moto
}

/// Ecommerce specific data to pass during authorization/settlement.
@objcMembers public class EcommerceInfo: NSObject {
    /// Identifies eCommerce vs mail order / telephone order (MOTO) transactions.
    /// Default value is `EcommerceChannel.ecom`.
    public var channel: EcommerceChannel
    /// The expected shipping month.
    /// Default value is the date of one day in the future.
    public var shipDay: Int?
    /// The expected shipping month.
    /// Default value is the month of one day in the future.
    public var shipMonth: Int?

    public required override init() {
        let tomorrowDate = Date.tomorrow
        let calanderDate = Calendar.current.dateComponents([.day, .month],
                                                           from: tomorrowDate)

        self.channel = .ecom
        self.shipDay = calanderDate.day
        self.shipMonth = calanderDate.month
    }
}
