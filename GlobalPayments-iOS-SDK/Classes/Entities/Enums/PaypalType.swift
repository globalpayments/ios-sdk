import Foundation

public enum PaypalType: String, Mappable, CaseIterable {
    case charge
    case authorize
    
    public init?(value: String?) {
        guard let value = value,
              let usageMode = PaypalType(rawValue: value) else { return nil }
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
