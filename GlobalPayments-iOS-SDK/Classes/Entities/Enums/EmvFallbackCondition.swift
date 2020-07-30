import Foundation

public enum EmvFallbackCondition: String {
    case chipReadFailure = "ICC_TERMINAL_ERROR"
    case noCandidateList = "NO_CANDIDATE_LIST"
}
