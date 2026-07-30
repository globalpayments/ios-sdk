//
//  DigitalWalletProvider.swift
//  GlobalPayments-iOS-SDK
//

import Foundation

/// Identifies the digital-wallet provider offered on a Hosted Payment Page.
/// Used inside `PaymentMethodConfiguration.digitalWalletProviders` when creating
/// an HPP link via `PayByLinkService` with `type = .hosted_payment_page`.
public enum DigitalWalletProvider: String, CaseIterable {
    /// Google Pay — GP-API contract value is lowercase
    case googlePay = "googlepay"
    /// Apple Pay — GP-API contract value is lowercase
    case applePay = "applepay"
    /// Click to Pay — GP-API contract value is uppercase
    case clickToPay = "CLICK_TO_PAY"

    public init?(value: String?) {
        guard let value = value,
              let provider = DigitalWalletProvider(rawValue: value) else { return nil }
        self = provider
    }
}
