#ifndef TransactionType_h
#define TransactionType_h

/// Indicates the transaction type.
typedef NS_OPTIONS(NSInteger, TransactionType) {
    /// Indicates a decline.
    TransactionTypeDecline                = 1 << 0,
    /// Indicates an account verify.
    TransactionTypeVerify                 = 1 << 1,
    /// Indicates a capture/add to batch.
    TransactionTypeCapture                = 1 << 2,
    /// Indicates an authorization without capture.
    TransactionTypeAuth                   = 1 << 3,
    /// Indicates a refund/return.
    TransactionTypeRefund                 = 1 << 4,
    /// Indicates a reversal.
    TransactionTypeReversal               = 1 << 5,
    /// Indicates a sale/charge/authorization with capture.
    TransactionTypeSale                   = 1 << 6,
    /// Indicates an edit.
    TransactionTypeEdit                   = 1 << 7,
    /// Indicates a void.
    TransactionTypeVoid                   = 1 << 8,
    /// Indicates value should be added.
    TransactionTypeAddValue               = 1 << 9,
    /// Indicates a balance inquiry.
    TransactionTypeBalance                = 1 << 10,
    /// Indicates an activation.
    TransactionTypeActivate               = 1 << 11,
    /// Indicates an alias should be added.
    TransactionTypeAlias                  = 1 << 12,
    /// Indicates the payment method should be replaced.
    TransactionTypeReplace                = 1 << 13,
    /// Indicates a reward.
    TransactionTypeReward                 = 1 << 14,
    /// Indicates a deactivation.
    TransactionTypeDeactivate             = 1 << 15,
    /// Indicates a batch close.
    TransactionTypeBatchClose             = 1 << 16,
    /// Indicates a resource should be created.
    TransactionTypeCreate                 = 1 << 17,
    /// Indicates a resource should be deleted.
    TransactionTypeDelete                 = 1 << 18,
    /// Indicates a benefit withdrawal.
    TransactionTypeBenefitWithdrawal      = 1 << 19,
    /// Indicates a resource should be fetched.
    TransactionTypeFetch                  = 1 << 20,
    /// Indicates a resource type should be searched.
    TransactionTypeSearch                 = 1 << 21,
    /// Indicates a hold.
    TransactionTypeHold                   = 1 << 22,
    /// Indicates a release.
    TransactionTypeRelease                = 1 << 23,
    /// Indicates a verify 3d Secure enrollment transaction
    TransactionTypeVerifyEnrolled         = 1 << 24,
    /// Indicates a verify 3d secure verify signature transaction
    TransactionTypeVerifySignature        = 1 << 25,
    /// Indcates a TokenUpdateExpiry Transaction
    TransactionTypeTokenUpdate            = 1 << 26,
    /// Indicates a Token Delete Transaction
    TransactionTypeTokenDelete            = 1 << 27,
    /// Indicates a verify authentication 3DS2 call
    TransactionTypeVerifyAuthentication   = 1 << 28,
    /// Indicates an Initiate Authentication 3DS2 call
    TransactionTypeInitiateAuthentication = 1 << 29,
    /// Indicates a DataCollect.
    TransactionTypeDataCollect            = 1 << 30,
    /// Indicates a PreAuthCompletion.
    TransactionTypePreAuthCompletion      = 1 << 31,
    /// Indicates a DccRateLookup.
    TransactionTypeDccRateLookup          = 1 << 32,
    TransactionTypeIncrement              = 1 << 33,
    /// Indicates a token only transaction
    TransactionTypeTokenize               = 1 << 34
};

#endif /* TransactionType_h */
