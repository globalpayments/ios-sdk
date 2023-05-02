import Foundation

public class PayLinkService {
    
    public static func create(payLink: PayLinkData , amount: NSDecimalNumber) -> AuthorizationBuilder {
        return AuthorizationBuilder(transactionType: .create)
            .withAmount(amount)
            .withPayLinkData(payLink)
    }
    
    public static func edit(payLinkId: String?, amount: NSDecimalNumber?) -> ManagementBuilder{
        return ManagementBuilder(transactionType: .payLinkUpdate)
            .withPaymentLink(payLinkId)
            .withAmount(amount)
    }
    
    public static func payLinkDetail(_ payLinkId: String?) -> TransactionReportBuilder<PayLinkSummary> {
        TransactionReportBuilder<PayLinkSummary>(reportType: .payLinkDetail).withPayLinkId(payLinkId)
    }
    
    public static func findPayLink(page: Int, pageSize: Int) -> TransactionReportBuilder<PagedResult<PayLinkSummary>> {
        TransactionReportBuilder<PagedResult<PayLinkSummary>>(reportType: .findPayLinkPaged)
            .withPaging(page, pageSize)
    }
}
