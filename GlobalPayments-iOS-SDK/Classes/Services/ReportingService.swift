import Foundation

public class ReportingService {

    // MARK: - Transactions

    public static func findTransactions() -> TransactionReportBuilder<[TransactionSummary]> {
        return TransactionReportBuilder<[TransactionSummary]>(reportType: .findTransactions)
    }

    public static func findSettlementTransactions() -> TransactionReportBuilder<[TransactionSummary]> {
        return TransactionReportBuilder<[TransactionSummary]>(reportType: .findSettlementTransactions)
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

    public static func settlementDisputeDetail(disputeId: String) -> TransactionReportBuilder<DisputeSummary> {
        return TransactionReportBuilder<DisputeSummary>(reportType: .settlementDisputeDetail)
            .withSettlementDisputeId(disputeId)
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

    public static func findDisputeDocument(id: String, disputeId: String) -> TransactionReportBuilder<DocumentMetadata> {
        return TransactionReportBuilder<DocumentMetadata>(reportType: .disputeDocument)
            .withDisputeId(disputeId)
            .withDocumentId(id)
    }

    // MARK: - Other

    public static func activity() -> TransactionReportBuilder<[TransactionSummary]> {
        return TransactionReportBuilder<[TransactionSummary]>(reportType: .activity)
    }
}
