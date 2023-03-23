import Foundation

public enum TransactionModifier: String {
    case none
    case incremental
    case additional
    case offline
    case levelII
    case levelIII
    case fraudDecline
    case chipDecline
    case cashBack
    case voucher
    case recurring
    case hostedRequest
    case encryptedMobile
    case secure3D
    case alternativePaymentMethod
    case decryptedMobile
    case merchant
    
    public init?(value: String?) {
        guard let value = value,
              let status = TransactionModifier(rawValue: value) else { return nil }
        self = status
    }
}
