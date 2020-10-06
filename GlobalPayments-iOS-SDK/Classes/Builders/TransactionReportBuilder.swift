import Foundation

@objcMembers public class TransactionReportBuilder<TResult>: ReportBuilder<TResult> {

    lazy var searchCriteriaBuilder: SearchCriteriaBuilder<TResult> = {
        return SearchCriteriaBuilder<TResult>(reportBuilder: self)
    }()

    var deviceId: String? { return searchCriteriaBuilder.uniqueDeviceId }
    var endDate: Date? { return searchCriteriaBuilder.endDate }
    var startDate: Date? { return searchCriteriaBuilder.startDate }
    var transactionId: String?
    var page: Int?
    var pageSize: Int?
    var transactionOrderBy: TransactionSortProperty?
    var transactionOrder: SortDirection?
    var depositId: String?
    var depositOrderBy: DepositSortProperty?
    var depositOrder: SortDirection?
    var disputeOrderBy: DisputeSortProperty?
    var disputeOrder: SortDirection?

    /// Sets the device ID as criteria for the report.
    /// - Parameter deviceId: The device ID
    /// - Returns: TransactionReportBuilder<TResult>
    public func withDeviceId(_ deviceId: String) -> TransactionReportBuilder<TResult> {
        searchCriteriaBuilder.uniqueDeviceId = deviceId
        return self
    }

    /// Sets the end date ID as criteria for the report.
    /// - Parameter endDate: The end date ID
    /// - Returns: TransactionReportBuilder<TResult>
    public func withEndDate(_ endDate: Date?) -> TransactionReportBuilder<TResult> {
        searchCriteriaBuilder.endDate = endDate
        return self
    }

    public func withTimeZoneConversion(_ timeZoneConversion: TimeZoneConversion?) -> TransactionReportBuilder<TResult> {
        self.timeZoneConversion = timeZoneConversion
        return self
    }

    /// Sets the gateway transaction ID as criteria for the report.
    /// - Parameter transactionId: The gateway transaction ID
    /// - Returns: TransactionReportBuilder<TResult>
    public func withTransactionId(_ transactionId: String?) -> TransactionReportBuilder<TResult> {
        self.transactionId = transactionId
        return self
    }

    /// Sets the gateway deposit ID as criteria for the report.
    /// - Parameter depositId: The gateway deposit ID
    /// - Returns: TransactionReportBuilder<TResult>
    public func withDepositId(_ depositId: String?) -> TransactionReportBuilder<TResult> {
        self.depositId = depositId
        return self
    }

    /// Set the gateway paging criteria for the report.
    /// - Parameters:
    ///   - page: Page number
    ///   - pageSize: Page size
    /// - Returns: TransactionReportBuilder<TResult>
    public func withPaging(_ page: Int, _ pageSize: Int) -> TransactionReportBuilder<TResult> {
        self.page = page
        self.pageSize = pageSize
        return self
    }

    /// Set the gateway transaction order by criteria for the report.
    /// - Parameters:
    ///   - transactionSortProperty: Order by transaction sort property
    ///   - direction: Order by direction
    /// - Returns: TransactionReportBuilder<TResult>
    public func orderBy(transactionSortProperty: TransactionSortProperty,
                        _ direction: SortDirection = .ascending) -> TransactionReportBuilder<TResult> {
        self.transactionOrderBy = transactionSortProperty
        self.transactionOrder = direction
        return self
    }

    /// Set the gateway deposit order by criteria for the report.
    /// - Parameters:
    ///   - depositOrderBy: Ordered by deposit property
    ///   - direction: Order by direction
    /// - Returns: TransactionReportBuilder<TResult>
    public func orderBy(depositOrderBy: DepositSortProperty,
                        _ direction: SortDirection = .ascending) -> TransactionReportBuilder<TResult> {
        self.depositOrderBy = depositOrderBy
        self.depositOrder = direction
        return self
    }

    /// Set the gateway dispute order by criteria for the report.
    /// - Parameters:
    ///   - disputeOrderBy: Order by dispute property
    ///   - direction: Order by direction
    /// - Returns: TransactionReportBuilder<TResult>
    public func orderBy(disputeOrderBy: DisputeSortProperty,
                        _ direction: SortDirection = .ascending) -> TransactionReportBuilder<TResult> {
        self.disputeOrderBy = disputeOrderBy
        self.disputeOrder = direction
        return self
    }

    public func `where`<T>(_ criteria: SearchCriteria, _ value: T) -> SearchCriteriaBuilder<TResult> {
        return searchCriteriaBuilder.and(criteria: criteria, value: value)
    }

    public func `where`<T>(_ criteria: DataServiceCriteria, _ value: T) -> SearchCriteriaBuilder<TResult> {
        return searchCriteriaBuilder.and(criteria: criteria, value: value)
    }

    public override func setupValidations() {
        validations.of(reportType: .transactionDetail)
            .check(propertyName: "transactionId")?.isNotNil()

        validations.of(reportType: .activity)
            .check(propertyName: "transactionId")?.isNil()
    }
}
