import Foundation

 public class TransactionReportBuilder<TResult>: ReportBuilder<TResult> {

    lazy var searchCriteriaBuilder: SearchCriteriaBuilder<TResult> = {
        return SearchCriteriaBuilder<TResult>(reportBuilder: self)
    }()

    var deviceId: String? { return searchCriteriaBuilder.uniqueDeviceId }
    var endDate: Date? { return searchCriteriaBuilder.endDate }
    var startDate: Date? { return searchCriteriaBuilder.startDate }
    var transactionId: String?
    var idempotencyKey: String?
    var order: SortDirection?
    var transactionOrderBy: TransactionSortProperty?
    var depositOrderBy: DepositSortProperty?
    var depositStatus: DepositStatus?
    var disputeOrderBy: DisputeSortProperty?
    var storedPaymentMethodOrderBy: StoredPaymentMethodSortProperty?
    var actionOrderBy: ActionSortProperty?
    var disputeDocuments: [DocumentInfo]?
    var disputeDocumentId: String?
    var payByLinkOrderBy: PayByLinkSortProperty?
    var payByLinkId: String?
    var authenticationOrderBy: AuthenticationSortProperty?

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

    /// Sets the start date ID as criteria for the report.
    /// - Parameter startDate: The start date ID
    /// - Returns: TransactionReportBuilder<TResult>
    public func withStartDate(_ startDate: Date?) -> TransactionReportBuilder<TResult> {
          searchCriteriaBuilder.startDate = startDate
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

    /// Sets the gateway action id as criteria for the report.
    /// - Parameter id: The gateway action id
    /// - Returns: TResult
    public func withActionId(_ id: String?) -> TransactionReportBuilder<TResult> {
        searchCriteriaBuilder.actionId = id
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
        self.order = direction
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
        self.order = direction
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
        self.order = direction
        return self
    }

    /// Set the gateway stored payment method order by criteria for the report.
    /// - Parameters:
    ///   - storedPaymentMethodOrderBy: Order by property
    ///   - direction: Order by direction
    /// - Returns: TransactionReportBuilder<TResult>
    public func orderBy(storedPaymentMethodOrderBy: StoredPaymentMethodSortProperty,
                        _ direction: SortDirection = .ascending) -> TransactionReportBuilder<TResult> {
        self.storedPaymentMethodOrderBy = storedPaymentMethodOrderBy
        self.order = direction
        return self
    }

    /// Set the gateway action order by criteria for the report.
    /// - Parameters:
    ///   - actionOrderBy: Order by property
    ///   - direction: Order by direction
    /// - Returns: TransactionReportBuilder<TResult>
    public func orderBy(actionOrderBy: ActionSortProperty,
                        _ direction: SortDirection = .ascending) -> TransactionReportBuilder<TResult> {
        self.actionOrderBy = actionOrderBy
        self.order = direction
        return self
    }

    /// Set the gateway authentication order by criteria for the report.
    /// - Parameters:
    ///   - authenticationOrderBy: Order by property
    ///   - direction: Order by direction
    /// - Returns: TransactionReportBuilder<TResult>
    public func orderBy(authenticationOrderBy: AuthenticationSortProperty,
                        _ direction: SortDirection = .ascending) -> TransactionReportBuilder<TResult> {
        self.authenticationOrderBy = authenticationOrderBy
        self.order = direction
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

    /// Sets the gateway stored payment method id as a critria for the report.
    /// - Parameter storedPaymentMethodId: The stored payment method id
    /// - Returns: TransactionReportBuilder<TResult>
    public func withStoredPaymentMethodId(_ storedPaymentMethodId: String?) -> TransactionReportBuilder<TResult> {
        searchCriteriaBuilder.storedPaymentMethodId = storedPaymentMethodId
        return self
    }
    
    /// Sets the gateway DisputeDocumentId as criteria for the report
    /// - Parameter documentId: The dispute document id
    /// - Returns: TransactionReportBuilder<TResult>
    public func withDisputeDocumentId(_ documentId: String) -> TransactionReportBuilder<TResult> {
        disputeDocumentId = documentId
        return self
    }

    /// Sets the gateway authentication ID as criteria for the report.
    /// - Parameter authenticationId: The gateway authentication id
    /// - Returns: TransactionReportBuilder<TResult>
    public func withAuthenticationId(_ authenticationId: String?) -> TransactionReportBuilder<TResult> {
        searchCriteriaBuilder.authenticationId = authenticationId
        return self
    }

    /// Sets the authentication source as criteria for the report.
    /// - Parameter source: The authentication source
    /// - Returns: TransactionReportBuilder<TResult>
    public func withSource(_ source: String?) -> TransactionReportBuilder<TResult> {
        searchCriteriaBuilder.source = source
        return self
    }

    /// Sets the 3DS directory server transaction reference as criteria for the report.
    /// - Parameter directoryServerTransactionReference: The 3DS directory server transaction reference
    /// - Returns: TransactionReportBuilder<TResult>
    public func withDirectoryServerTransactionReference(_ directoryServerTransactionReference: String?) -> TransactionReportBuilder<TResult> {
        searchCriteriaBuilder.directoryServerTransactionReference = directoryServerTransactionReference
        return self
    }

    /// Sets the 3DS server transaction reference as criteria for the report.
    /// - Parameter threeDSServerTransactionReference: The 3DS server transaction reference
    /// - Returns: TransactionReportBuilder<TResult>
    public func withThreeDSServerTransactionReference(_ threeDSServerTransactionReference: String?) -> TransactionReportBuilder<TResult> {
        searchCriteriaBuilder.threeDSServerTransactionReference = threeDSServerTransactionReference
        return self
    }

    /// Sets the 3DS liability shift as criteria for the report.
    /// - Parameter liabilityShift: The 3DS liability shift
    /// - Returns: TransactionReportBuilder<TResult>
    public func withLiabilityShift(_ liabilityShift: String?) -> TransactionReportBuilder<TResult> {
        searchCriteriaBuilder.liabilityShift = liabilityShift
        return self
    }

    /// Sets the 3DS authentication value as criteria for the report.
    /// - Parameter authenticationValue: The 3DS authentication value
    /// - Returns: TransactionReportBuilder<TResult>
    public func withAuthenticationValue(_ authenticationValue: String?) -> TransactionReportBuilder<TResult> {
        searchCriteriaBuilder.authenticationValue = authenticationValue
        return self
    }

    /// Sets the 3DS eci as criteria for the report.
    /// - Parameter eci: The 3DS eci
    /// - Returns: TransactionReportBuilder<TResult>
    public func withEci(_ eci: String?) -> TransactionReportBuilder<TResult> {
        searchCriteriaBuilder.eci = eci
        return self
    }

    /// Sets the 3DS message version as criteria for the report.
    /// - Parameter messageVersion: The 3DS message version
    /// - Returns: TransactionReportBuilder<TResult>
    public func withMessageVersion(_ messageVersion: String?) -> TransactionReportBuilder<TResult> {
        searchCriteriaBuilder.messageVersion = messageVersion
        return self
    }
    
    public func orderBy(_ orderBy: PayByLinkSortProperty, direction: SortDirection = .ascending) -> TransactionReportBuilder<TResult> {
        self.payByLinkOrderBy = orderBy
        self.order = direction
        return self
    }
    
    public func withPayByLinkId(_ payByLinkId: String?) -> TransactionReportBuilder<TResult> {
        self.searchCriteriaBuilder.payByLinkId = payByLinkId
        self.payByLinkId = payByLinkId
        return self
    }

    /// Sets the payment method category as criteria for the report.
    /// - Parameter paymentMethodCategory: The payment method category
    /// - Returns: TransactionReportBuilder<TResult>
    public func withPaymentMethodCategory(_ paymentMethodCategory: PaymentMethodCategory?) -> TransactionReportBuilder<TResult> {
        searchCriteriaBuilder.paymentMethodCategory = paymentMethodCategory
        return self
    }

    /// Sets the payment method brand as criteria for the report.
    /// - Parameter paymentMethodBrand: The payment method brand
    /// - Returns: TransactionReportBuilder<TResult>
    public func withPaymentMethodBrand(_ paymentMethodBrand: String?) -> TransactionReportBuilder<TResult> {
        searchCriteriaBuilder.cardBrand = paymentMethodBrand
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

    public func `where`(_ storedPaymentMethodStatus: StoredPaymentMethodStatus) -> SearchCriteriaBuilder<TResult> {
        return searchCriteriaBuilder.and(storedPaymentMethodStatus: storedPaymentMethodStatus)
    }

    public func `where`(_ paymentMethod: PaymentMethod) -> SearchCriteriaBuilder<TResult> {
        return searchCriteriaBuilder.and(paymentMethod: paymentMethod)
    }

    public override func setupValidations() {
        validations.of(reportType: .transactionDetail)
            .check(propertyName: "transactionId")?.isNotNil()
        
        validations.of(reportType: .payByLinkDetail)
            .check(propertyName: "payByLinkId")?.isNotNil()

        validations.of(reportType: .activity)
            .check(propertyName: "transactionId")?.isNil()

        validations.of(transactionType: .refund)
            .when(propertyName: "amount")?.isNotNil()?
            .check(propertyName: "currency")?.isNotNil()

        validations.of(transactionType: .documentDisputeDetail)
            .when(propertyName: "disputeDocumentId")?.isNotNil()
    }
}
