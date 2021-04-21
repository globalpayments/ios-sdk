import Foundation

public enum DeliveryTimeFrame: String, Mappable, CaseIterable {
    case electronicDelivery = "ELECTRONIC_DELIVERY"
    case sameDay = "SAME_DAY"
    case overnight = "OVERNIGHT"
    case twoDaysOrMore = "TWO_DAYS_OR_MORE"

    public init?(value: String?) {
        guard let value = value,
              let timeFrame = DeliveryTimeFrame(rawValue: value) else { return nil }
        self = timeFrame
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
