import Foundation

public enum CustomerAuthenticationMethod: String, Mappable {
    case notAuthenticated = "NOT_AUTHENTICATED"
    case merchantSystemAuthentication = "MERCHANT_SYSTEM_AUTHENTICATION"
    case federatedIdAuthentication = "FEDERATED_ID_AUTHENTICATION"
    case issuerCredentialAuthentication = "ISSUER_CREDENTIAL_AUTHENTICATION"
    case thirdPartyAuthentication = "THIRD_PARTY_AUTHENTICATION"
    case fidoAuthentication = "FIDO_AUTHENTICATION"

    public init?(value: String?) {
        guard let value = value,
              let method = CustomerAuthenticationMethod(rawValue: value) else { return nil }
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
