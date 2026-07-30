//
//  Surcharge.swift
//  GlobalPayments-iOS-SDK
//

import Foundation

/// Represents a surcharge rule for a specific card type on an HPP payment link.
/// Used in `PayByLinkData.surcharge` when creating a `HOSTED_PAYMENT_PAGE` link.
public class Surcharge: NSObject {
    /// The card type to which the surcharge applies (e.g. `"DEBIT"`, `"CREDIT"`, `"COMMERCIAL"`).
    public var cardType: String?
    /// The surcharge amount as a whole-number string in the minor units of the transaction currency
    /// (e.g. `"100001"` for 1000.01 USD).
    public var amount: String?

    public init(cardType: String? = nil, amount: String? = nil) {
        self.cardType = cardType
        self.amount = amount
    }
}
