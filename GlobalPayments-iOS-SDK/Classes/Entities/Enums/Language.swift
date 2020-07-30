import Foundation

public enum Language: String, Mappable {
    case english = "EN"
    case spanish = "ES"

    public func mapped(for target: Target) -> String? {
        switch target {
        case .gpApi:
            return self.rawValue
        default:
            return nil
        }
    }
}
