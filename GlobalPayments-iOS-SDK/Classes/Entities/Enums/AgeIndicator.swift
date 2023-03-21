import Foundation

public enum AgeIndicator: String, Mappable {
    case noAccount = "NO_ACCOUNT"
    case noChange = "NO_CHANGE"
    case thisTransaction = "THIS_TRANSACTION"
    case lessThanThirtyDays = "LESS_THAN_THIRTY_DAYS"
    case thirtyToSixtyDays = "THIRTY_TO_SIXTY_DAYS"
    case moreThenSixtyDay = "MORE_THEN_SIXTY_DAYS"

    public init?(value: String?) {
        guard let value = value,
              let indicator = AgeIndicator(rawValue: value) else { return nil }
        self = indicator
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
