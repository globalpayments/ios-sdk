import Foundation

 public class UserReportBuilder<TResult>: ReportBuilder<TResult> {
    
    lazy var searchCriteriaBuilder: SearchCriteriaBuilder<TResult> = {
        return SearchCriteriaBuilder<TResult>(reportBuilder: self)
    }()
    
    public var order: SortDirection?
    public var transactionType: TransactionType?
    public var transactionModifier: TransactionModifier = .none
    public var transactionOrderBy: TransactionSortProperty?
    public var merchantStatus: UserStatus?
    public var id: String?
    var endDate: Date? { return searchCriteriaBuilder.endDate }
    var startDate: Date? { return searchCriteriaBuilder.startDate }

    public func withModifier(_ transactionModifier: TransactionModifier) -> UserReportBuilder<TResult> {
        self.transactionModifier = transactionModifier
        return self
    }
    
    public func withPaging(_ page: Int, _ pageSize: Int) -> UserReportBuilder<TResult> {
        self.page = page
        self.pageSize = pageSize
        return self
    }
    
    public func withMerchantStatus(_ value: UserStatus?) -> UserReportBuilder<TResult> {
        self.merchantStatus = value
        return self
    }
    
    public func orderBy(transactionSortProperty: TransactionSortProperty,
                        _ direction: SortDirection = .ascending) -> UserReportBuilder<TResult> {
        self.transactionOrderBy = transactionSortProperty
        self.order = direction
        return self
    }
    
    public func withId(_ value: String?) -> UserReportBuilder<TResult> {
        self.id = value
        return self
    }
    
    public func withStartDate(_ startDate: Date?) -> UserReportBuilder<TResult> {
        searchCriteriaBuilder.startDate = startDate
        return self
    }
    
    public func withEndDate(_ endDate: Date?) -> UserReportBuilder<TResult> {
        searchCriteriaBuilder.endDate = endDate
        return self
    }
    
    public func withMerchantId(_ merchantId: String?) -> UserReportBuilder<TResult> {
        searchCriteriaBuilder.merchantId = merchantId
        return self
    }
}
