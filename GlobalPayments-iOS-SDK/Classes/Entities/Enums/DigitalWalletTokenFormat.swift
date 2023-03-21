import Foundation

public enum DigitalWalletTokenFormat: String, Mappable, CaseIterable {
    
    case CARD_NUMBER = "CARD_NUMBER"
    case CARD_TOKEN = "CARD_TOKEN"

    public init?(value: String?) {
        guard let value = value,
              let status = DigitalWalletTokenFormat(rawValue: value) else { return nil }
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
