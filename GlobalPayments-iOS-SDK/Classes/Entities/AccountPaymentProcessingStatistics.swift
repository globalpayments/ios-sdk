import Foundation

/// Usage/limit statistics returned for a Funds Management Account (FMA).
public class AccountPaymentProcessingStatistics {
    public var cardTransactionLimitAmount: String?
    public var cardMonthlyLimitAmount: String?
    public var bankTransferPerTransactionLimitAmount: String?
    public var bankTransferMonthlyLimitAmount: String?
    public var bankTransferMonthToDateProcessedAmount: String?
    public var cardMonthToDateProcessedAmount: String?
    public var availableBalanceAmount: String?
    public var pendingBalanceAmount: String?
    public var reserveBalanceAmount: String?
    public var allowedNegativeBalanceAmount: String?
    public var disablePayoutCardLimitPercentage: String?
    public var disablePayoutBankTransferLimitPercentage: String?
    public var cardMonthToDateProcessedPercentage: String?
    public var bankTransferMonthToDateProcessedPercentage: String?
}

extension AccountPaymentProcessingStatistics: JsonToObject {

    public static func mapToObject<T>(_ doc: JsonDoc) -> T? {
        let statistics = AccountPaymentProcessingStatistics()
        statistics.cardTransactionLimitAmount = doc.getValue(key: "card_transaction_limit_amount")
        statistics.cardMonthlyLimitAmount = doc.getValue(key: "card_monthly_limit_amount")
        statistics.bankTransferPerTransactionLimitAmount = doc.getValue(key: "bank_transfer_per_transaction_limit_amount")
        statistics.bankTransferMonthlyLimitAmount = doc.getValue(key: "bank_transfer_monthly_limit_amount")
        statistics.bankTransferMonthToDateProcessedAmount = doc.getValue(key: "bank_transfer_month_to_date_processed_amount")
        statistics.cardMonthToDateProcessedAmount = doc.getValue(key: "card_month_to_date_processed_amount")
        statistics.availableBalanceAmount = doc.getValue(key: "available_balance_amount")
        statistics.pendingBalanceAmount = doc.getValue(key: "pending_balance_amount")
        statistics.reserveBalanceAmount = doc.getValue(key: "reserve_balance_amount")
        statistics.allowedNegativeBalanceAmount = doc.getValue(key: "allowed_negative_balance_amount")
        statistics.disablePayoutCardLimitPercentage = doc.getValue(key: "disable_payout_card_limit_percentage")
        statistics.disablePayoutBankTransferLimitPercentage = doc.getValue(key: "disable_payout_bank_transfer_limit_percentage")
        statistics.cardMonthToDateProcessedPercentage = doc.getValue(key: "card_month_to_date_processed_percentage")
        statistics.bankTransferMonthToDateProcessedPercentage = doc.getValue(key: "bank_transfer_month_to_date_processed_percentage")
        return statistics as? T
    }
}
