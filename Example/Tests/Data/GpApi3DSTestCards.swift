import Foundation

struct GpApi3DSTestCards {
    // V1
    static let cardholderNotEnrolledV1 = "4917000000000087"
    static let cardholderEnrolledV1 = "4012001037141112"
    // V2.1
    static let cardAuthSuccessfulV21 = "4263970000005262"
    static let cardAuthSuccessfulNoMethodUrlV21 = "4222000006724235"
    static let cardAuthAttemptedButNotSuccessfulV21 = "4012001037167778"
    static let cardAuthFailedV21 = "4012001037461114"
    static let cardAuthIssuerRejectedV21 = "4012001038443335"
    static let cardAuthCouldNotBePreformedV21 = "4012001037484447"
    static let cardChallengeRequiredV21 = "4012001038488884"
    // V2.2
    static let cardAuthSuccessfulV22 = "4222000006285344"
    static let cardAuthSuccessfulNoMethodUrlV22 = "4222000009719489"
    static let cardAuthAttemptedButNotSuccessfulV22 = "4222000005218627"
    static let cardAuthFailedV22 = "4222000002144131"
    static let cardAuthIssuerRejectedV22 = "4222000007275799"
    static let cardAuthCouldNotBePreformedV22 = "4222000008880910"
    static let cardChallengeRequiredV22 = "4222000001227408"
}
