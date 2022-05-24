import Foundation

public enum EncryptedMobileType: String, Mappable, CaseIterable {
    
    case APPLE_PAY = "APPLEPAY"
    case GOOGLE_PAY = "PAY_BY_GOOGLE"

    public init?(value: String?) {
        guard let value = value,
              let status = EncryptedMobileType(rawValue: value) else { return nil }
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
