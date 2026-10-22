import Foundation

/// Processing limit values that may be updated via `PATCH /accounts/{id}`.
public class AccountProcessingLimits {
    public var cardTransactionLimitAmount: String?
    public var cardMonthlyLimitAmount: String?
    public var bankTransferTransactionLimitAmount: String?
    public var bankTransferMonthlyLimitAmount: String?
    public var disablePayoutCardLimitPercentage: String?
    public var disablePayoutBankTransferLimitPercentage: String?
    public var allowedNegativeBalanceAmount: String?

    public init() {}
}
