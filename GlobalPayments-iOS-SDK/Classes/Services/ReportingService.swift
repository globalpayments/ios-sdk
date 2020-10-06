import Foundation

public class ReportingService {

    // MARK: - Transactions

    public static func findTransactions(transactionId: String? = nil) -> TransactionReportBuilder<[TransactionSummary]> {
        return TransactionReportBuilder<[TransactionSummary]>(reportType: .findTransactions)
            .withTransactionId(transactionId)
    }

    public static func transactionDetail(transactionId: String?) -> TransactionReportBuilder<TransactionSummary> {
        return TransactionReportBuilder<TransactionSummary>(reportType: .transactionDetail)
            .withTransactionId(transactionId)
    }

    // MARK: - Deposits

    public static func findDeposits() -> TransactionReportBuilder<[DepositSummary]> {
        return TransactionReportBuilder<[DepositSummary]>(reportType: .findDeposits)
    }

    public static func depositDetail(depositId: String? = nil) -> TransactionReportBuilder<DepositSummary> {
        return TransactionReportBuilder<DepositSummary>(reportType: .findDeposit)
            .withDepositId(depositId)
    }

    // MARK: - Disputes

    public func findDisputes() -> TransactionReportBuilder<[DisputeSummary]> {
        return TransactionReportBuilder<[DisputeSummary]>(reportType: .findDisputes)
    }

    // MARK: - Other

    public static func activity() -> TransactionReportBuilder<[TransactionSummary]> {
        return TransactionReportBuilder<[TransactionSummary]>(reportType: .activity)
    }
}
