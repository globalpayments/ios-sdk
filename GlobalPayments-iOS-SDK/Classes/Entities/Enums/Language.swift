import Foundation

public enum Language: String, Mappable, CaseIterable, Codable {
    case english = "EN"
    case spanish = "ES"

    public init?(value: String?) {
        guard let value = value,
              let language = Language(rawValue: value) else { return nil }
        self = language
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
