import Foundation

@objcMembers public class TransactionReportBuilder<TResult>: ReportBuilder<TResult> {

    lazy var searchCriteriaBuilder: SearchCriteriaBuilder<TResult> = {
        return SearchCriteriaBuilder<TResult>(reportBuilder: self)
    }()

    var deviceId: String? { return searchCriteriaBuilder.uniqueDeviceId }
    var endDate: Date? { return searchCriteriaBuilder.endDate }
    var startDate: Date? { return searchCriteriaBuilder.startDate }
    var transactionId: String?
    var idempotencyKey: String?
    var page: Int?
    var pageSize: Int?
    var transactionOrderBy: TransactionSortProperty?
    var transactionOrder: SortDirection?
    var depositOrderBy: DepositSortProperty?
    var depositOrder: SortDirection?
    var depositStatus: DepositStatus?
    var disputeOrderBy: DisputeSortProperty?
    var disputeOrder: SortDirection?
    var disputeDocuments: [DocumentInfo]?

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

    /// Sets the gateway documents
    /// - Parameter disputeDocuments: The gateway documents list
    /// - Returns: TransactionReportBuilder<TResult>
    public func withDisputeDocuments(_ disputeDocuments: [DocumentInfo]?) -> TransactionReportBuilder<TResult> {
        self.disputeDocuments = disputeDocuments
        return self
    }

    /// Sets the gateway document ID
    /// - Parameter documentId: The gateway document ID
    /// - Returns: TransactionReportBuilder<TResult>
    public func withDocumentId(_ documentId: String?) -> TransactionReportBuilder<TResult> {
        searchCriteriaBuilder.disputeDocumentReference = documentId
        return self
    }

    /// Sets the gateway deposit ID as criteria for the report.
    /// - Parameter depositReference: The gateway deposit ID
    /// - Returns: TransactionReportBuilder<TResult>
    public func withDepositReference(_ depositReference: String?) -> TransactionReportBuilder<TResult> {
        searchCriteriaBuilder.depositReference = depositReference
        return self
    }

    /// Sets the deposit status as criteria for the report.
    /// - Parameter depositStatus: The gateway deposit status
    /// - Returns: TransactionReportBuilder<TResult>
    public func withDepositStatus(_ depositStatus: DepositStatus?) -> TransactionReportBuilder<TResult> {
        self.depositStatus = depositStatus
        return self
    }

    /// Field submitted in the request that is used to ensure idempotency is maintained within the action
    /// - Parameter idempotencyKey: The idempotency key
    /// - Returns: TransactionReportBuilder<TResult>
    public func withIdempotencyKey(_ idempotencyKey: String?) -> TransactionReportBuilder<TResult> {
        self.idempotencyKey = idempotencyKey
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
    /// - Parameter disputeId: The gateway settlement dispute id
    /// - Returns: TransactionReportBuilder<TResult>
    public func withDisputeId(_ disputeId: String?) -> TransactionReportBuilder<TResult> {
        searchCriteriaBuilder.disputeReference = disputeId
        return self
    }

    /// Sets the gateway settlement dispute id as criteria for the report.
    /// - Parameter disputeId: The gateway dispute ID
    /// - Returns: TransactionReportBuilder<TResult>
    public func withSettlementDisputeId(_ disputeId: String?) -> TransactionReportBuilder<TResult> {
        searchCriteriaBuilder.settlementDisputeId = disputeId
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

    /// Set the amount for the report.
    /// - Parameter amount: The gateway amount
    /// - Returns: TransactionReportBuilder<TResult>
    public func withAmount(_ amount: NSDecimalNumber?) -> TransactionReportBuilder<TResult> {
        searchCriteriaBuilder.amount = amount
        return self
    }

    public func `where`<T>(_ searchCriteria: SearchCriteria, _ value: T) -> SearchCriteriaBuilder<TResult> {
        return searchCriteriaBuilder.and(searchCriteria: searchCriteria, value: value)
    }

    public func `where`<T>(_ dataServiceCriteria: DataServiceCriteria, _ value: T) -> SearchCriteriaBuilder<TResult> {
        return searchCriteriaBuilder.and(dataServiceCriteria: dataServiceCriteria, value: value)
    }

    public func `where`(_ transactionStatus: TransactionStatus?) -> SearchCriteriaBuilder<TResult> {
        return searchCriteriaBuilder.and(transactionStatus: transactionStatus)
    }

    public func `where`(_ disputeStage: DisputeStage) -> SearchCriteriaBuilder<TResult> {
        return searchCriteriaBuilder.and(disputeStage: disputeStage)
    }

    public func `where`(_ disputeStatus: DisputeStatus) -> SearchCriteriaBuilder<TResult> {
        return searchCriteriaBuilder.and(disputeStatus: disputeStatus)
    }

    public func `where`(_ depositStatus: DepositStatus) -> SearchCriteriaBuilder<TResult> {
        return searchCriteriaBuilder.and(depositStatus: depositStatus)
    }

    public func `where`(_ channel: Channel) -> SearchCriteriaBuilder<TResult> {
        return searchCriteriaBuilder.and(channel: channel)
    }

    public func `where`(_ paymentEntryMode: PaymentEntryMode) -> SearchCriteriaBuilder<TResult> {
        return searchCriteriaBuilder.and(paymentEntryMode: paymentEntryMode)
    }

    public func `where`(_ paymentType: PaymentType) -> SearchCriteriaBuilder<TResult> {
        return searchCriteriaBuilder.and(paymentType: paymentType)
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
