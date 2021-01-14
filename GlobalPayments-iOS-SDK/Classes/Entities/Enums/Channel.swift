import Foundation

public enum Channel: String, Mappable, CaseIterable, Codable {
    case cardPresent = "CP"
    case cardNotPresent = "CNP"

    public init?(value: String?) {
        guard let value = value,
              let channel = Channel(rawValue: value) else { return nil }
        self = channel
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
