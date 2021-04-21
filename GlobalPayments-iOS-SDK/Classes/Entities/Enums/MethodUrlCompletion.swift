import Foundation

public enum MethodUrlCompletion: String, Mappable {
    case yes
    case no
    case unavailable

    public func mapped(for target: Target) -> String? {
        switch target {
        case .gpApi:
            return self.rawValue.uppercased()
        default:
            return nil
        }
    }
}
