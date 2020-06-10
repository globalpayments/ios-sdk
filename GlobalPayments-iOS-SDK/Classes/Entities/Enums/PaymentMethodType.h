#ifndef PaymentMethodType_h
#define PaymentMethodType_h

/// Indicates a payment method type.
typedef NS_OPTIONS(NSUInteger, PaymentMethodType) {
    /// Indicates a payment method reference.
    /// - Description: Should be accompanied by a gateway transaction ID.
    PaymentMethodTypeReference = 1 << 0,
    /// Indicates a credit or PIN-less debit account.
    /// - Description: Should be accompanied by a token, card number, or track data.
    PaymentMethodTypeCredit    = 1 << 1,
    /// Indicates a PIN debit account.
    /// - Description: Should be accompanied by track data and a PIN block.
    PaymentMethodTypeDebit     = 1 << 2,
    /// Indicates an EBT account.
    /// - Description: Should be accompanied by track data and a PIN block.
    PaymentMethodTypeEbt       = 1 << 3,
    /// Indicates cash as the payment method.
    PaymentMethodTypeCash      = 1 << 4,
    /// Indicates an ACH/eCheck account.
    /// - Description: Should be accompanied by a token or an account number and routing number.
    PaymentMethodTypeAch       = 1 << 5,
    /// Indicates a gift/loyalty/stored value account.
    /// - Description: Should be accompanied by a token, card number, alias, or track data.
    PaymentMethodTypeGift      = 1 << 6,
    /// Indicates a recurring payment method.
    /// - Description: Should be accompanied by a payment method key.
    PaymentMethodTypeRecurring = 1 << 7
};

#endif /* PaymentMethodType_h */
