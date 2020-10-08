import Foundation

public enum DisputeResult: String, Mappable {
    case pending = "PENDING"
    case fulfilled = "FULFILLED"
    case won = "WON"
    case lost = "LOST"
    case accepted = "ACCEPTED"

    init?(value: String?) {
        guard let value = value,
              let result = DisputeResult(rawValue: value) else { return nil }
        self = result
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
