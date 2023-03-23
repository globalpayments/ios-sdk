import Foundation

@objcMembers public class UserReportBuilder<TResult>: ReportBuilder<TResult> {
    
    public var order: SortDirection?
    public var transactionType: TransactionType?
    public var transactionModifier: TransactionModifier = .none

    public func withModifier(_ transactionModifier: TransactionModifier) -> UserReportBuilder<TResult> {
        self.transactionModifier = transactionModifier
        return self
    }
    
    public func withPaging(_ page: Int, _ pageSize: Int) -> UserReportBuilder<TResult> {
        self.page = page
        self.pageSize = pageSize
        return self
    }
}
