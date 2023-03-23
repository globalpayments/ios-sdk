import Foundation

public class ReportingService {

    // MARK: - Transactions

    public static func findTransactions() -> TransactionReportBuilder<[TransactionSummary]> {
        TransactionReportBuilder<[TransactionSummary]>(reportType: .findTransactions)
    }

    public static func findTransactionsPaged(page: Int, pageSize: Int, transactionId: String? = nil) -> TransactionReportBuilder<PagedResult<TransactionSummary>> {
        TransactionReportBuilder<PagedResult<TransactionSummary>>(reportType: .findTransactionsPaged)
            .withTransactionId(transactionId)
            .withPaging(page, pageSize)
    }

    public static func findSettlementTransactions() -> TransactionReportBuilder<[TransactionSummary]> {
        TransactionReportBuilder<[TransactionSummary]>(reportType: .findSettlementTransactions)
    }

    public static func findSettlementTransactionsPaged(page: Int, pageSize: Int) -> TransactionReportBuilder<PagedResult<TransactionSummary>> {
        TransactionReportBuilder<PagedResult<TransactionSummary>>(reportType: .findSettlementTransactionsPaged)
            .withPaging(page, pageSize)
    }

    public static func transactionDetail(transactionId: String) -> TransactionReportBuilder<TransactionSummary> {
        TransactionReportBuilder<TransactionSummary>(reportType: .transactionDetail)
            .withTransactionId(transactionId)
    }

    // MARK: - Deposits

    public static func findDeposits() -> TransactionReportBuilder<[DepositSummary]> {
        TransactionReportBuilder<[DepositSummary]>(reportType: .findDeposits)
    }

    public static func findDepositsPaged(page: Int, pageSize: Int) -> TransactionReportBuilder<PagedResult<DepositSummary>> {
        TransactionReportBuilder<PagedResult<DepositSummary>>(reportType: .findDepositsPaged)
            .withPaging(page, pageSize)
    }

    public static func depositDetail(depositReference: String) -> TransactionReportBuilder<DepositSummary> {
        TransactionReportBuilder<DepositSummary>(reportType: .depositDetail)
            .withDepositReference(depositReference)
    }

    // MARK: - Disputes

    public static func findDisputes() -> TransactionReportBuilder<[DisputeSummary]> {
        TransactionReportBuilder<[DisputeSummary]>(reportType: .findDisputes)
    }

    public static func findDisputesPaged(page: Int, pageSize: Int) -> TransactionReportBuilder<PagedResult<DisputeSummary>> {
        TransactionReportBuilder<PagedResult<DisputeSummary>>(reportType: .findDisputesPaged)
            .withPaging(page, pageSize)
    }

    public static func disputeDetail(disputeId: String) -> TransactionReportBuilder<DisputeSummary> {
        TransactionReportBuilder<DisputeSummary>(reportType: .disputeDetail)
            .withDisputeId(disputeId)
    }

    public static func findSettlementDisputes() -> TransactionReportBuilder<[DisputeSummary]> {
        TransactionReportBuilder<[DisputeSummary]>(reportType: .findSettlementDisputes)
    }

    public static func findSettlementDisputesPaged(page: Int, pageSize: Int) -> TransactionReportBuilder<PagedResult<DisputeSummary>> {
        TransactionReportBuilder<PagedResult<DisputeSummary>>(reportType: .findSettlementDisputesPaged)
            .withPaging(page, pageSize)
    }

    public static func settlementDisputeDetail(disputeId: String) -> TransactionReportBuilder<DisputeSummary> {
        TransactionReportBuilder<DisputeSummary>(reportType: .settlementDisputeDetail)
            .withSettlementDisputeId(disputeId)
    }

    public static func acceptDispute(id: String) -> TransactionReportBuilder<DisputeAction> {
        TransactionReportBuilder<DisputeAction>(reportType: .acceptDispute)
            .withDisputeId(id)
    }

    public static func challangeDispute(id: String, documents: [DocumentInfo]?) -> TransactionReportBuilder<DisputeAction> {
        TransactionReportBuilder<DisputeAction>(reportType: .challangeDispute)
            .withDisputeId(id)
            .withDisputeDocuments(documents)
    }

    public static func findDisputeDocument(id: String, disputeId: String) -> TransactionReportBuilder<DocumentMetadata> {
        TransactionReportBuilder<DocumentMetadata>(reportType: .disputeDocument)
            .withDisputeId(disputeId)
            .withDocumentId(id)
    }

    // MARK: - Stored Payment Method

    public static func storedPaymentMethodDetail(storedPaymentMethodId: String) -> TransactionReportBuilder<StoredPaymentMethodSummary> {
        TransactionReportBuilder<StoredPaymentMethodSummary>(reportType: .storedPaymentMethodDetail)
            .withStoredPaymentMethodId(storedPaymentMethodId)
    }

    public static func findStoredPaymentMethodsPaged(page: Int, pageSize: Int) -> TransactionReportBuilder<PagedResult<StoredPaymentMethodSummary>> {
        TransactionReportBuilder<PagedResult<StoredPaymentMethodSummary>>(reportType: .findStoredPaymentMethodsPaged)
            .withPaging(page, pageSize)
    }

    public static func documentDisputeDetail(_ disputeId: String) -> TransactionReportBuilder<DisputeDocument> {
            TransactionReportBuilder<DisputeDocument>(reportType: .documentDisputeDetail)
                .withDisputeId(disputeId)
    }

    // MARK: - Actions

    public static func actionDetail(actionId: String) -> TransactionReportBuilder<ActionSummary> {
        TransactionReportBuilder<ActionSummary>(reportType: .actionDetail)
            .withActionId(actionId)
    }

    public static func findActionsPaged(page: Int, pageSize: Int) -> TransactionReportBuilder<PagedResult<ActionSummary>> {
        TransactionReportBuilder<PagedResult<ActionSummary>>(reportType: .findActionsPaged)
            .withPaging(page, pageSize)
    }

    // MARK: - Other

    public static func activity() -> TransactionReportBuilder<[TransactionSummary]> {
        TransactionReportBuilder<[TransactionSummary]>(reportType: .activity)
    }
    
    public static func findMerchants(_ page: Int, pageSize: Int) -> UserReportBuilder<PagedResult<MerchantSummary>> {
        return UserReportBuilder<PagedResult<MerchantSummary>>(reportType: .findMerchantsPaged)
            .withModifier(.merchant)
            .withPaging(page, pageSize)
    }
}
