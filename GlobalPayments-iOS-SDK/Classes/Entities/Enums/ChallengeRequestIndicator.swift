import Foundation

public enum ChallengeRequestIndicator: String, Mappable, CaseIterable {
    case noPreference = "NO_PREFERENCE"
    case challengePreferred = "CHALLENGE_PREFERRED"
    case challengeMandated = "CHALLENGE_MANDATED"
    case noChallengeRequested = "NO_CHALLENGE_REQUESTED"
    case challengeRequestedPromptForWhitelist = "CHALLENGE_REQUESTED_PROMPT_FOR_WHITELIST"
    case noChallengeRequestedTransactionRiskAnalysisPerformed = "NO_CHALLENGE_REQUESTED_TRANSACTION_RISK_ANALYSIS_PERFORMED"
    case noChallengeRequestedDataShareOnly = "NO_CHALLENGE_REQUESTED_DATA_SHARE_ONLY"
    case noChallengeRequestedScaAlreadyPerformed = "NO_CHALLENGE_REQUESTED_SCA_ALREADY_PERFORMED"
    case noChallengeRequestedWhitelist = "NO_CHALLENGE_REQUESTED_WHITELIST"

    public init?(value: String?) {
        guard let value = value,
              let indicator = ChallengeRequestIndicator(rawValue: value) else { return nil }
        self = indicator
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
