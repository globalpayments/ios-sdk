//
//  PaymentMethodConfiguration.swift
//  GlobalPayments-iOS-SDK
//

import Foundation
public class PaymentMethodConfiguration: NSObject {
    
    ///Gets or sets the challenge request indicator for 3D Secure authentication.
    public var challengeRequestIndicator: ChallengeRequestIndicator?
    
    ///Gets or sets the exemption status for Strong Customer Authentication (SCA).
    public var exemptStatus: ExemptStatus?
    
    ///Gets or sets a value indicating whether the billing address is required.
    public var isBillingAddressRequired: Bool?
    
    ///Indicates whether the shipping address is required on the hosted payment page.
    public var isShippingAddressEnabled: Bool?
    
    ///Indicates whether the shipping address can be changed by the customer on the PayPal review page.
    public var isAddressOverrideAllowed: Bool?
    
    ///Indicates whether to store the card as part of a transaction.
    public var storageMode: StorageMode?
}
