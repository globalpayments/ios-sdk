//
//  PayByLinkOrder.swift
//  GlobalPayments-iOS-SDK
//

import Foundation

public class PayByLinkOrder {
    
    /// The total order amount, if different from the payment amount.
    public var amount: String?
    
    /// The currency code (ISO 4217) for the order.
    public var currency: String?
    
    /// The merchant's reference for the order.
    public var reference: String?
    
    /// The country code (ISO 3166-1 alpha-2) associated with the payment or merchant.
    public var country: String?
    
    /// The channel through which the payment link was created or is intended to be used.
    public var channel: String?
}
