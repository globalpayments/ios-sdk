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
    var depositOrderBy: DepositSortProperty?
    var depositOrder: SortDirection?
    var depositStatus: DepositStatus?
    var disputeOrderBy: DisputeSortProperty?
    var disputeOrder: SortDirection?
    var disputeDocuments: [DisputeDocument]?

    /// Sets the device ID as criteria for the report.
    /// - Parameter deviceId: The device ID
    /// - Returns: TransactionReportBuilder<TResult>
    public func withDeviceId(_ deviceId: String) -> TransactionReportBuilder<TResult> {
        searchCriteriaBuilder.uniqueDeviceId = deviceId
        return self
    }

    /// Sets Acquirer reference number
    /// - Parameter arn: Arn number
    /// - Returns: TransactionReportBuilder<TResult>
    public func withArn(_ arn: String?) -> TransactionReportBuilder<TResult> {
        searchCriteriaBuilder.aquirerReferenceNumber = arn
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

    /// Sets the gateway account name
    /// - Parameter accountName: The gateway account name
    /// - Returns: TransactionReportBuilder<TResult>
    public func withAccountName(_ accountName: String?) -> TransactionReportBuilder<TResult> {
        searchCriteriaBuilder.accountName = accountName
        return self
    }

    public func withDisputeDocuments(_ disputeDocuments: [DisputeDocument]?) -> TransactionReportBuilder<TResult> {
        self.disputeDocuments = disputeDocuments
        return self
    }

    /// Sets the gateway deposit ID as criteria for the report.
    /// - Parameter depositId: The gateway deposit ID
    /// - Returns: TransactionReportBuilder<TResult>
    public func withDepositId(_ depositId: String?) -> TransactionReportBuilder<TResult> {
        searchCriteriaBuilder.depositReference = depositId
        return self
    }

    /// Sets the deposit status as criteria for the report.
    /// - Parameter depositStatus: The gateway deposit status
    /// - Returns: TransactionReportBuilder<TResult>
    public func withDepositStatus(_ depositStatus: DepositStatus?) -> TransactionReportBuilder<TResult> {
        self.depositStatus = depositStatus
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

    /// Sets the gateway dispute ID as criteria for the report.
    /// - Parameter disputeId: The gateway dispute ID
    /// - Returns: TransactionReportBuilder<TResult>
    public func withDisputeId(_ disputeId: String?) -> TransactionReportBuilder<TResult> {
        searchCriteriaBuilder.disputeReference = disputeId
        return self
    }

    /// Set the dispute status for the report.
    /// - Parameter disputeStatus: The gateway dispute status
    /// - Returns: TransactionReportBuilder<TResult>
    public func withDisputeStatus(_ disputeStatus: DisputeStatus?) -> TransactionReportBuilder<TResult> {
        searchCriteriaBuilder.disputeStatus = disputeStatus
        return self
    }

    /// Set the dispute stage for the report.
    /// - Parameter disputeStage: The gateway dispute stage
    /// - Returns: TransactionReportBuilder<TResult>
    public func withDisputeStage(_ disputeStage: DisputeStage?) -> TransactionReportBuilder<TResult> {
        searchCriteriaBuilder.disputeStage = disputeStage
        return self
    }

    /// Set the adjustment funding for the report.
    /// - Parameter adjustmentFunding: The gateway adjustment funding
    /// - Returns: TransactionReportBuilder<TResult>
    public func withAdjustmentFunding(_ adjustmentFunding: AdjustmentFunding?) -> TransactionReportBuilder<TResult> {
        searchCriteriaBuilder.adjustmentFunding = adjustmentFunding
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

        validations.of(transactionType: .refund)
            .when(propertyName: "amount")?.isNotNil()?
            .check(propertyName: "currency")?.isNotNil()
    }
}
