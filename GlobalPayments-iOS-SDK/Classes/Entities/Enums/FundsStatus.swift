import Foundation

public enum FundsStatus: String, Mappable, CaseIterable {

    case captured = "CAPTURED"
    case declined = "DECLINED"

    public init?(value: String?) {
        guard let value = value,
              let status = FundsStatus(rawValue: value) else { return nil }
        self = status
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
