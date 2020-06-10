#ifndef TransactionType_h
#define TransactionType_h

/// Indicates the transaction type.
typedef NS_OPTIONS(NSUInteger, TransactionType) {
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
    /// Indicates a DccRateLookup.
    TransactionTypeDccRateLookup          = 1 << 26,
    TransactionTypeIncrement              = 1 << 27,
    TransactionTypeCashOut                = 1 << 28,
    TransactionTypeDataCollect            = 1 << 29,
    TransactionTypeVerifyAuthentication   = 1 << 30,
    TransactionTypePreAuthCompletion      = 1 << 31,
    TransactionTypeInitiateAuthentication = 1 << 32,
    TransactionTypeSendFile               = 1 << 33,
    /// Indcates a TokenUpdateExpiry Transaction
    TransactionTypeTokenUpdate            = 1 << 34,
    TransactionTypeTokenDelete            = 1 << 35
};

#endif /* TransactionType_h */
