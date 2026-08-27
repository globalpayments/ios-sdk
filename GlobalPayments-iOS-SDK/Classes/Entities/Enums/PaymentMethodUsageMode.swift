import Foundation

public enum PaymentMethodUsageMode: String, Mappable, CaseIterable {
    case single = "SINGLE"
    case multiple = "MULTIPLE"
    case useNetworkToken = "USE_NETWORK_TOKEN"
    
    public init?(value: String?) {
        guard let value = value,
              let usageMode = PaymentMethodUsageMode(rawValue: value) else { return nil }
        self = usageMode
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
