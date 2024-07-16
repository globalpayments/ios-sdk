import Foundation

public class PayByLinkService {
    
    public static func create(payByLink: PayByLinkData , amount: NSDecimalNumber) -> AuthorizationBuilder {
        return AuthorizationBuilder(transactionType: .create)
            .withAmount(amount)
            .withPayByLinkData(payByLink)
    }
    
    public static func edit(payByLinkId: String?, amount: NSDecimalNumber?) -> ManagementBuilder{
        return ManagementBuilder(transactionType: .payByLinkUpdate)
            .withPaymentLink(payByLinkId)
            .withAmount(amount)
    }
    
    public static func payByLinkDetail(_ payByLinkId: String?) -> TransactionReportBuilder<PayByLinkSummary> {
        TransactionReportBuilder<PayByLinkSummary>(reportType: .payByLinkDetail).withPayByLinkId(payByLinkId)
    }
    
    public static func findPayByLink(page: Int, pageSize: Int) -> TransactionReportBuilder<PagedResult<PayByLinkSummary>> {
        TransactionReportBuilder<PagedResult<PayByLinkSummary>>(reportType: .findPayByLinkPaged)
            .withPaging(page, pageSize)
    }
}
