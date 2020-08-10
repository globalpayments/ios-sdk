import Foundation

public class ReportingService {

    public static func findTransactions(transactionId: String? = nil) -> TransactionReportBuilder<[TransactionSummary]> {
        return TransactionReportBuilder<[TransactionSummary]>(reportType: .findTransactions)
            .withTransactionId(transactionId)
    }

    public static func findDeposits() -> TransactionReportBuilder<[DepositSummary]> {
        return TransactionReportBuilder<[DepositSummary]>(reportType: .findDeposits)
    }

    public func findDisputes() -> TransactionReportBuilder<[DisputeSummary]> {
        return TransactionReportBuilder<[DisputeSummary]>(reportType: .findDisputes)
    }

    public static func activity() -> TransactionReportBuilder<[TransactionSummary]> {
        return TransactionReportBuilder<[TransactionSummary]>(reportType: .activity)
    }

    public static func transactionDetail(transactionId: String?) -> TransactionReportBuilder<TransactionSummary> {
        return TransactionReportBuilder<TransactionSummary>(reportType: .transactionDetail)
            .withTransactionId(transactionId)
    }
}
