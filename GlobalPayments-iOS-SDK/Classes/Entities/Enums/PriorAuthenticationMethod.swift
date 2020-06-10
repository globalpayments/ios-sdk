import Foundation

@objc public enum PriorAuthenticationMethod: Int {
    case frictionlessAuthentication
    case challengeOccured
    case avsVerified
    case otherIssuerMethod
}
