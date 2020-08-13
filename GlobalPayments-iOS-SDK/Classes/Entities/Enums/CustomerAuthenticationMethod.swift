import Foundation

public enum CustomerAuthenticationMethod {
    case notAuthenticated
    case merchantSystemAuthentication
    case federatedIdAuthentication
    case issuerCredentialAuthentication
    case thirdPartyAuthentication
    case fidoAuthentication
}

