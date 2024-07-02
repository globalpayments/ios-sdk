import Foundation

/// Indicates the transaction type.
public struct TransactionType: OptionSet, Hashable {
    public let rawValue: Int

    public init(rawValue: Int) {
        self.rawValue = rawValue
    }
    /// Indicates a decline.
    public static let decline                = TransactionType(rawValue: 1 << 0)
    /// Indicates an account verify.
    public static let verify                 = TransactionType(rawValue: 1 << 1)
    /// Indicates a capture/add to batch.
    public static let capture                = TransactionType(rawValue: 1 << 2)
    /// Indicates an authorization without capture.
    public static let auth                   = TransactionType(rawValue: 1 << 3)
    /// Indicates a refund/return.
    public static let refund                 = TransactionType(rawValue: 1 << 4)
    /// Indicates a reversal.
    public static let reversal               = TransactionType(rawValue: 1 << 5)
    /// Indicates a sale/charge/authorization with capture.
    public static let sale                   = TransactionType(rawValue: 1 << 6)
    /// Indicates an edit.
    public static let edit                   = TransactionType(rawValue: 1 << 7)
    /// Indicates a void.
    public static let void                   = TransactionType(rawValue: 1 << 8)
    /// Indicates value should be added.
    public static let addValue               = TransactionType(rawValue: 1 << 9)
    /// Indicates a balance inquiry.
    public static let balance                = TransactionType(rawValue: 1 << 10)
    /// Indicates an activation.
    public static let activate               = TransactionType(rawValue: 1 << 11)
    /// Indicates an alias should be added.
    public static let alias                  = TransactionType(rawValue: 1 << 12)
    /// Indicates the payment method should be replaced.
    public static let replace                = TransactionType(rawValue: 1 << 13)
    /// Indicates a reward.
    public static let reward                 = TransactionType(rawValue: 1 << 14)
    /// Indicates a deactivation.
    public static let deactivate             = TransactionType(rawValue: 1 << 15)
    /// Indicates a batch close.
    public static let batchClose             = TransactionType(rawValue: 1 << 16)
    /// Indicates a resource should be created.
    public static let create                 = TransactionType(rawValue: 1 << 17)
    /// Indicates a resource should be deleted.
    public static let delete                 = TransactionType(rawValue: 1 << 18)
    /// Indicates a benefit withdrawal.
    public static let benefitWithdrawal      = TransactionType(rawValue: 1 << 19)
    /// Indicates a resource should be fetched.
    public static let fetch                  = TransactionType(rawValue: 1 << 20)
    /// Indicates a resource type should be searched.
    public static let search                 = TransactionType(rawValue: 1 << 21)
    /// Indicates a hold.
    public static let hold                   = TransactionType(rawValue: 1 << 22)
    /// Indicates a release.
    public static let release                = TransactionType(rawValue: 1 << 23)
    /// Indicates a verify 3d Secure enrollment transaction
    public static let verifyEnrolled         = TransactionType(rawValue: 1 << 24)
    /// Indicates a verify 3d secure verify signature transaction
    public static let verifySignature        = TransactionType(rawValue: 1 << 25)
    /// Indcates a TokenUpdateExpiry Transaction
    public static let tokenUpdate            = TransactionType(rawValue: 1 << 26)
    /// Indicates a Token Delete Transaction
    public static let tokenDelete            = TransactionType(rawValue: 1 << 27)
    /// Indicates a verify authentication 3DS2 call
    public static let verifyAuthentication   = TransactionType(rawValue: 1 << 28)
    /// Indicates an Initiate Authentication 3DS2 call
    public static let initiateAuthentication = TransactionType(rawValue: 1 << 29)
    /// Indicates a DataCollect.
    public static let dataCollect            = TransactionType(rawValue: 1 << 30)
    /// Indicates a PreAuthCompletion.
    public static let preAuthCompletion      = TransactionType(rawValue: 1 << 31)
    /// Indicates a DccRateLookup.
    public static let dccRateLookup          = TransactionType(rawValue: 1 << 32)
    public static let increment              = TransactionType(rawValue: 1 << 33)
    /// Indicates a token only transaction
    public static let tokenize               = TransactionType(rawValue: 1 << 34)
    public static let cashOut                = TransactionType(rawValue: 1 << 35)
    public static let payment                = TransactionType(rawValue: 1 << 36)
    public static let cashAdvance            = TransactionType(rawValue: 1 << 37)
    /// Indicates a detokenization transaction
    public static let detokenize             = TransactionType(rawValue: 1 << 38)
    /// Indicates a transaction reauthorization
    public static let reauth                 = TransactionType(rawValue: 1 << 39)
    /// Indicates a Dispute Document Details report.
    public static let documentDisputeDetail  = TransactionType(rawValue: 1 << 40)
    
    public static let payLinkUpdate          = TransactionType(rawValue: 1 << 41)
    
    public static let confirm                = TransactionType(rawValue: 1 << 42)
    
    public static let splitFunds             = TransactionType(rawValue: 1 << 43)
    
    public static let addFunds               = TransactionType(rawValue: 1 << 44)
    
    public static let transferFunds          = TransactionType(rawValue: 1 << 45)
    
    public static let uploadDocument         = TransactionType(rawValue: 1 << 46)
}
