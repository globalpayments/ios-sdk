import Foundation

public class ReportingService {

    // MARK: - Transactions

    public static func findTransactions() -> TransactionReportBuilder<[TransactionSummary]> {
        return TransactionReportBuilder<[TransactionSummary]>(reportType: .findTransactions)
    }

    public static func transactionDetail(transactionId: String) -> TransactionReportBuilder<TransactionSummary> {
        return TransactionReportBuilder<TransactionSummary>(reportType: .transactionDetail)
            .withTransactionId(transactionId)
    }

    // MARK: - Deposits

    public static func findDeposits() -> TransactionReportBuilder<[DepositSummary]> {
        return TransactionReportBuilder<[DepositSummary]>(reportType: .findDeposits)
    }

    public static func depositDetail(depositId: String) -> TransactionReportBuilder<DepositSummary> {
        return TransactionReportBuilder<DepositSummary>(reportType: .depositDetail)
            .withDepositId(depositId)
    }

    // MARK: - Disputes

    public static func findDisputes() -> TransactionReportBuilder<[DisputeSummary]> {
        return TransactionReportBuilder<[DisputeSummary]>(reportType: .findDisputes)
    }

    public static func disputeDetail(disputeId: String) -> TransactionReportBuilder<DisputeSummary> {
        return TransactionReportBuilder<DisputeSummary>(reportType: .disputeDetail)
            .withDisputeId(disputeId)
    }

    public static func findSettlementDisputes() -> TransactionReportBuilder<[DisputeSummary]> {
        return TransactionReportBuilder<[DisputeSummary]>(reportType: .findSettlementDisputes)
    }

    public static func acceptDispute(id: String) -> TransactionReportBuilder<DisputeAction> {
        return TransactionReportBuilder<DisputeAction>(reportType: .acceptDispute)
            .withDisputeId(id)
    }

    public static func challangeDispute(id: String, documents: [DocumentInfo]?) -> TransactionReportBuilder<DisputeAction> {
        return TransactionReportBuilder<DisputeAction>(reportType: .challangeDispute)
            .withDisputeId(id)
            .withDisputeDocuments(documents)
    }

    // MARK: - Other

    public static func activity() -> TransactionReportBuilder<[TransactionSummary]> {
        return TransactionReportBuilder<[TransactionSummary]>(reportType: .activity)
    }
}
