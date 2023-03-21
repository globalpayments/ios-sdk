import Foundation

public enum ShippingMethod: String, Mappable, CaseIterable {
    case billingAddress = "BILLING_ADDRESS"
    case anotherVerifiedAddress = "ANOTHER_VERIFIED_ADDRESS"
    case unverifiedAddress = "UNVERIFIED_ADDRESS"
    case shipToStore = "SHIP_TO_STORE"
    case digitalGoods = "DIGITAL_GOODS"
    case travelAndEventTickets = "TRAVEL_AND_EVENT_TICKETS"
    case other = "OTHER"

    public init?(value: String?) {
        guard let value = value,
              let method = ShippingMethod(rawValue: value) else { return nil }
        self = method
    }

    public func mapped(for target: Target) -> String? {
        switch target {
        case .gpApi:
            return self.rawValue
        default:
            return nil
        }
    }
}
