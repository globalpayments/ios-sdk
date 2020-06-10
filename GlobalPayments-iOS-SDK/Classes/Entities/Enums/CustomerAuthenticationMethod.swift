import Foundation

@objc public enum CustomerAuthenticationMethod: Int {
    case notAuthenticated
    case merchantSystemAuthentication
    case federatedIdAuthentication
    case issuerCredentialAuthentication
    case thirdPartyAuthentication
    case fidoAuthentication
}

