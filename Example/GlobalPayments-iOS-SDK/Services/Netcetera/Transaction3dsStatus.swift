import Foundation

enum Transaction3dsStatus: String, Decodable {
    case AuthenticationSuccessful = "Y"
    case TransactionDenied = "N"
    case TechnicalProblem = "U"
    case AttemptsProcessing = "A"
    case ChallengeRequired = "C"
    case AuthenticationRejected = "R"
    case DecoupledAuthentication = "D"
    case InformationalPurposesOnly = "I"
}
