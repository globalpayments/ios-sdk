import Foundation

public enum AuthenticationSource: String, Mappable, CaseIterable {
    case browser = "BROWSER"
    case merchantInitiated = "MERCHANT_INITIATED"
    case mobileSDK = "MOBILE_SDK"

    public init?(value: String?) {
        guard let value = value,
              let source = AuthenticationSource(rawValue: value) else { return nil }
        self = source
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
