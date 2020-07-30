import Foundation

public enum Channel: String, Mappable {
    case cardPresent = "CP"
    case cardNotPresent = "CNP"

    public func mapped(for target: Target) -> String? {
        switch target {
        case .gpApi:
            return self.rawValue
        default:
            return nil
        }
    }
}
