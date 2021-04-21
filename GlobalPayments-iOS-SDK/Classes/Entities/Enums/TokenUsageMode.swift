import Foundation

public enum TokenUsageMode: String, Mappable {
    case single = "SINGLE"
    case multiple = "MULTIPLE"

    public func mapped(for target: Target) -> String? {
        switch target {
        case .gpApi:
            return self.rawValue
        default:
            return nil
        }
    }
}
