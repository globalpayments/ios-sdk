import Foundation

public enum ReorderIndicator: String, Mappable {
    case firstTimeOrder = "FIRST_TIME_ORDER"
    case reorder = "REORDER"

    public init?(value: String?) {
        guard let value = value,
              let indicator = ReorderIndicator(rawValue: value) else { return nil }
        self = indicator
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
