import Foundation

public enum PriorAuthenticationMethod: String, Mappable {
    case frictionlessAuthentication = "FRICTIONLESS_AUTHENTICATION"
    case challengeOccured = "CHALLENGE_OCCURRED"
    case avsVerified = "AVS_VERIFIED"
    case otherIssuerMethod = "OTHER_ISSUER_METHOD"

    public init?(value: String?) {
        guard let value = value,
              let method = PriorAuthenticationMethod(rawValue: value) else { return nil }
        self = method
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
