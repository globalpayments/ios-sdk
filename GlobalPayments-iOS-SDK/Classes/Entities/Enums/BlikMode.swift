import Foundation

/// BLIK processing mode. `levelZero` enables the streamlined BLIK Level 0 flow on GP-API.
public enum BlikMode: String, Mappable, CaseIterable {

    case levelZero = "level_zero"

    public init?(value: String?) {
        guard let value = value,
              let mode = BlikMode(rawValue: value) else { return nil }
        self = mode
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
