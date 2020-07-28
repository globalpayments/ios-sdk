import Foundation

public class TransactionReportBuilder<TResult>: ReportBuilder<TResult> {

    lazy var searchCriteriaBuilder: SearchCriteriaBuilder<TResult> = {
        return SearchCriteriaBuilder<TResult>(reportBuilder: self)
    }()

    var deviceId: String? { return searchCriteriaBuilder.uniqueDeviceId }
    var endDate: Date? { return searchCriteriaBuilder.endDate }
    var startDate: Date? { return searchCriteriaBuilder.startDate }
    var transactionId: String?
    var page: Int?
    var pageSize: Int?
    var orderProperty: TransactionSortProperty?
    var orderDirection: SortDirection?

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

    /// Set the gateway order by criteria for the report.
    /// - Parameters:
    ///   - orderProperty: Order by property
    ///   - orderDirection: Order by direction
    /// - Returns: TransactionReportBuilder<TResult>
    public func orderBy(_ orderProperty: TransactionSortProperty,
                        _ orderDirection: SortDirection = .ascending) -> TransactionReportBuilder<TResult> {
        self.orderProperty = orderProperty
        self.orderDirection = orderDirection
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
