import Foundation

public enum MethodUrlCompletion: String, Mappable, CaseIterable {
    case yes
    case no
    case unavailable

    public init?(value: String?) {
        guard let value = value,
              let methodUrlCompletion = MethodUrlCompletion(rawValue: value) else { return nil }
        self = methodUrlCompletion
    }

    public func mapped(for target: Target) -> String? {
        switch target {
        case .gpApi:
            return self.rawValue.uppercased()
        default:
            return nil
        }
    }
}
