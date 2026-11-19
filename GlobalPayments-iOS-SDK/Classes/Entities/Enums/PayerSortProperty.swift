import Foundation

public enum PayerSortProperty: String, Mappable, CaseIterable {
    case timeCreated = "TIME_CREATED"

    public init?(value: String?) {
        guard let value = value else { return nil }
        self.init(rawValue: value)
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
