import Foundation

/// Specify how the fraud filter should operate
public enum FraudFilterMode {
    /// Fraud filter will behave as configured in RealControl
    case none
    /// Disables the fraud filter
    case off
    /// Sets the fraud filter to passive mode
    case passive
}

/// Options when specifying HPP versions.
/// Useful with `HostedPaymentConfig`.
public enum HppVersion: String {
    /// HPP Version 1
    case one = "1"
    /// HPP Version 2
    case two = "2"
}

/// Hosted Payment Page (HPP) configuration
public class HostedPaymentConfig: NSObject {
    /// Allow card to be stored within the HPP
    public var cardStorageEnabled: Bool?
    /// Allow Dynamic Currency Conversion (DCC) to be available
    public var dynamicCurrencyConversionEnabled: Bool?
    /// Allow a consumer's previously stored cards to be shown
    public var displaySavedCards: Bool?
    /// Manner in which the fraud filter should operate
    public var fraudFilterMode: FraudFilterMode = .none
    /// The desired language for the HPP
    public var language: String?
    /// Text for the HPP's submit button
    public var paymentButtonText: String?
    /// iFrame Optimisation - dimensions
    public var postDimensions: String?
    /// iFrame Optimisation - response
    public var postResponse: String?
    /// URL to receive `POST` data of the HPP's result
    public var responseUrl: String?
    /// Denotes if Transaction Stability Score (TSS) should be active
    public var requestTransactionStabilityScore: Bool?
    /// Specify HPP version
    public var version: HppVersion?
}
