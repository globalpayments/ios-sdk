import Foundation

@objc public enum ShippingMethod: Int {
    case billingAddress
    case anotherVerifiedAddress
    case unverifiedAddress
    case shipToStore
    case digitalGoods
    case travelAndEventTickets
    case other
}
