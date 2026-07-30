//
//  DisplayConfiguration.swift
//  GlobalPayments-iOS-SDK
//

import Foundation

/// Configures iframe display options for a Hosted Payment Page (HPP) link.
/// Used in `PayByLinkData.displayConfiguration` when creating a `HOSTED_PAYMENT_PAGE` link.
public class DisplayConfiguration: NSObject {
    /// The domain for iframe dimension callbacks.
    public var iframeDimensionsDomain: String?
    /// The domain for iframe response callbacks.
    public var iframeResponseDomain: String?
}
