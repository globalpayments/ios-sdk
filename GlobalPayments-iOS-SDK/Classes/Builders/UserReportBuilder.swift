import Foundation

@objcMembers public class UserReportBuilder<TResult>: ReportBuilder<TResult> {
    
    public var order: SortDirection?
    public var transactionType: TransactionType?
    public var transactionModifier: TransactionModifier = .none
    public var transactionOrderBy: TransactionSortProperty?
    public var merchantStatus: UserStatus?
    public var id: String?

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
}
