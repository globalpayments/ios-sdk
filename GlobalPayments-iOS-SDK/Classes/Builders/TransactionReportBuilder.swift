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
    var monthlyFeeOrderBy: MonthlyFeeSortProperty?

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

    /// Sets the gateway batch reference as criteria for the report.
    /// - Parameter batchReference: The gateway batch reference
    /// - Returns: TransactionReportBuilder<TResult>
    public func withBatchReference(_ batchReference: String?) -> TransactionReportBuilder<TResult> {
        searchCriteriaBuilder.batchReference = batchReference
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

    /// Set the Monthly Fee Report order by criteria for the report.
    /// - Parameters:
    ///   - monthlyFeeOrderBy: Order by property
    ///   - direction: Order by direction
    /// - Returns: TransactionReportBuilder<TResult>
    public func orderBy(monthlyFeeOrderBy: MonthlyFeeSortProperty,
                        _ direction: SortDirection = .ascending) -> TransactionReportBuilder<TResult> {
        self.monthlyFeeOrderBy = monthlyFeeOrderBy
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

    /// Sets the merchant's order reference as criteria for the report.
    /// - Parameter orderReference: The merchant defined order reference
    /// - Returns: TransactionReportBuilder<TResult>
    public func withOrderReference(_ orderReference: String?) -> TransactionReportBuilder<TResult> {
        searchCriteriaBuilder.orderReference = orderReference
        return self
    }

    /// Sets the deposit id as criteria for the report. Used by the Settled Disputes report as `deposit.id`.
    /// - Parameter depositId: The deposit id
    /// - Returns: TransactionReportBuilder<TResult>
    public func withDepositId(_ depositId: String?) -> TransactionReportBuilder<TResult> {
        searchCriteriaBuilder.depositId = depositId
        return self
    }

    /// Sets the card brand reference as criteria for the report. Used by the Settled Disputes report.
    /// - Parameter brandReference: The unique reference created by the card brand
    /// - Returns: TransactionReportBuilder<TResult>
    public func withBrandReference(_ brandReference: String?) -> TransactionReportBuilder<TResult> {
        searchCriteriaBuilder.brandReference = brandReference
        return self
    }

    /// Sets the authorization code as criteria for the report. Used by the Settled Disputes report.
    /// - Parameter authCode: The code generated when the card is successfully authorized
    /// - Returns: TransactionReportBuilder<TResult>
    public func withAuthCode(_ authCode: String?) -> TransactionReportBuilder<TResult> {
        searchCriteriaBuilder.authCode = authCode
        return self
    }

    /// Sets the merchant defined reference as criteria for the report. Used by the Settled Disputes report.
    /// - Parameter referenceNumber: The merchant defined reference for the transaction
    /// - Returns: TransactionReportBuilder<TResult>
    public func withReferenceNumber(_ referenceNumber: String?) -> TransactionReportBuilder<TResult> {
        searchCriteriaBuilder.referenceNumber = referenceNumber
        return self
    }

    /// Sets the settlement code as criteria for the report.
    /// - Parameter settlementCode: The settlement code
    /// - Returns: TransactionReportBuilder<TResult>
    public func withSettlementCode(_ settlementCode: String?) -> TransactionReportBuilder<TResult> {
        searchCriteriaBuilder.settlementCode = settlementCode
        return self
    }

    /// Sets the settlement transaction reference as criteria for the report.
    /// - Parameter settlementTransactionReference: The settlement transaction reference
    /// - Returns: TransactionReportBuilder<TResult>
    public func withSettlementTransactionReference(_ settlementTransactionReference: String?) -> TransactionReportBuilder<TResult> {
        searchCriteriaBuilder.settlementTransactionReference = settlementTransactionReference
        return self
    }

    /// Sets the merchant doing business as name as criteria for the report.
    /// - Parameter merchantDbaName: The merchant dba name
    /// - Returns: TransactionReportBuilder<TResult>
    public func withMerchantDbaName(_ merchantDbaName: String?) -> TransactionReportBuilder<TResult> {
        searchCriteriaBuilder.merchantDbaName = merchantDbaName
        return self
    }

    /// Sets the merchant name as criteria for the report.
    /// - Parameter merchantName: The merchant name
    /// - Returns: TransactionReportBuilder<TResult>
    public func withMerchantName(_ merchantName: String?) -> TransactionReportBuilder<TResult> {
        searchCriteriaBuilder.merchantName = merchantName
        return self
    }

    /// Sets the terminal id as criteria for the report.
    /// - Parameter terminalId: The terminal id
    /// - Returns: TransactionReportBuilder<TResult>
    public func withTerminalId(_ terminalId: String?) -> TransactionReportBuilder<TResult> {
        searchCriteriaBuilder.terminalId = terminalId
        return self
    }

    /// Sets the merchant amount as criteria for the report.
    /// - Parameter merchantAmount: The merchant amount
    /// - Returns: TransactionReportBuilder<TResult>
    public func withMerchantAmount(_ merchantAmount: NSDecimalNumber?) -> TransactionReportBuilder<TResult> {
        searchCriteriaBuilder.merchantAmount = merchantAmount
        return self
    }

    /// Sets the charge type region as criteria for the report.
    /// - Parameter chargeTypeRegion: The charge type region
    /// - Returns: TransactionReportBuilder<TResult>
    public func withChargeTypeRegion(_ chargeTypeRegion: String?) -> TransactionReportBuilder<TResult> {
        searchCriteriaBuilder.chargeTypeRegion = chargeTypeRegion
        return self
    }

    /// Sets the start of the merchant transaction reference date range as criteria for the report.
    /// - Parameter startDate: The start date
    /// - Returns: TransactionReportBuilder<TResult>
    public func withStartTransactionTimeCreatedReference(_ startDate: Date?) -> TransactionReportBuilder<TResult> {
        searchCriteriaBuilder.startTransactionTimeCreatedReference = startDate
        return self
    }

    /// Sets the end of the merchant transaction reference date range as criteria for the report.
    /// - Parameter endDate: The end date
    /// - Returns: TransactionReportBuilder<TResult>
    public func withEndTransactionTimeCreatedReference(_ endDate: Date?) -> TransactionReportBuilder<TResult> {
        searchCriteriaBuilder.endTransactionTimeCreatedReference = endDate
        return self
    }

    /// Sets the settlement fee charge type as criteria for the report.
    /// - Parameter chargeType: The fee charge type
    /// - Returns: TransactionReportBuilder<TResult>
    public func withFeeChargeType(_ chargeType: String?) -> TransactionReportBuilder<TResult> {
        searchCriteriaBuilder.feeChargeType = chargeType
        return self
    }

    /// Sets the settlement fee total amount as criteria for the report.
    /// - Parameter totalAmount: The fee total amount
    /// - Returns: TransactionReportBuilder<TResult>
    public func withFeeTotalAmount(_ totalAmount: NSDecimalNumber?) -> TransactionReportBuilder<TResult> {
        searchCriteriaBuilder.feeTotalAmount = totalAmount
        return self
    }

    /// Sets the interchange program as criteria for the report.
    /// - Parameter program: The interchange program
    /// - Returns: TransactionReportBuilder<TResult>
    public func withInterchangeProgram(_ program: String?) -> TransactionReportBuilder<TResult> {
        searchCriteriaBuilder.interchangeProgram = program
        return self
    }

    /// Sets the interchange per item flat amount as criteria for the report.
    /// - Parameter amount: The interchange per item flat amount
    /// - Returns: TransactionReportBuilder<TResult>
    public func withInterchangePerItemFlatAmount(_ amount: NSDecimalNumber?) -> TransactionReportBuilder<TResult> {
        searchCriteriaBuilder.interchangePerItemFlatAmount = amount
        return self
    }

    /// Sets the interchange per item calculated amount as criteria for the report.
    /// - Parameter amount: The interchange per item calculated amount
    /// - Returns: TransactionReportBuilder<TResult>
    public func withInterchangePerItemCalculatedAmount(_ amount: NSDecimalNumber?) -> TransactionReportBuilder<TResult> {
        searchCriteriaBuilder.interchangePerItemCalculatedAmount = amount
        return self
    }

    /// Sets the interchange percentage as criteria for the report.
    /// - Parameter percentage: The interchange percentage
    /// - Returns: TransactionReportBuilder<TResult>
    public func withInterchangePercentage(_ percentage: String?) -> TransactionReportBuilder<TResult> {
        searchCriteriaBuilder.interchangePercentage = percentage
        return self
    }

    /// Sets the interchange percentage amount as criteria for the report.
    /// - Parameter amount: The interchange percentage amount
    /// - Returns: TransactionReportBuilder<TResult>
    public func withInterchangePercentageAmount(_ amount: NSDecimalNumber?) -> TransactionReportBuilder<TResult> {
        searchCriteriaBuilder.interchangePercentageAmount = amount
        return self
    }

    /// Sets the interchange total rate as criteria for the report.
    /// - Parameter totalRate: The interchange total rate
    /// - Returns: TransactionReportBuilder<TResult>
    public func withInterchangeTotalRate(_ totalRate: String?) -> TransactionReportBuilder<TResult> {
        searchCriteriaBuilder.interchangeTotalRate = totalRate
        return self
    }

    /// Sets the interchange total amount as criteria for the report.
    /// - Parameter amount: The interchange total amount
    /// - Returns: TransactionReportBuilder<TResult>
    public func withInterchangeTotalAmount(_ amount: NSDecimalNumber?) -> TransactionReportBuilder<TResult> {
        searchCriteriaBuilder.interchangeTotalAmount = amount
        return self
    }

    /// Sets the discount rate 1 percentage as criteria for the report.
    /// - Parameter percentage: The discount rate 1 percentage
    /// - Returns: TransactionReportBuilder<TResult>
    public func withDiscountRate1Percentage(_ percentage: String?) -> TransactionReportBuilder<TResult> {
        searchCriteriaBuilder.discountRate1Percentage = percentage
        return self
    }

    /// Sets the discount rate 2 percentage as criteria for the report.
    /// - Parameter percentage: The discount rate 2 percentage
    /// - Returns: TransactionReportBuilder<TResult>
    public func withDiscountRate2Percentage(_ percentage: String?) -> TransactionReportBuilder<TResult> {
        searchCriteriaBuilder.discountRate2Percentage = percentage
        return self
    }

    /// Sets the discount total amount as criteria for the report.
    /// - Parameter amount: The discount total amount
    /// - Returns: TransactionReportBuilder<TResult>
    public func withDiscountTotalAmount(_ amount: NSDecimalNumber?) -> TransactionReportBuilder<TResult> {
        searchCriteriaBuilder.discountTotalAmount = amount
        return self
    }

    /// Sets the exchange rate as criteria for the report.
    /// - Parameter exchangeRate: The exchange rate
    /// - Returns: TransactionReportBuilder<TResult>
    public func withExchangeRate(_ exchangeRate: String?) -> TransactionReportBuilder<TResult> {
        searchCriteriaBuilder.exchangeRate = exchangeRate
        return self
    }

    /// Sets the assessment total amount as criteria for the report.
    /// - Parameter amount: The assessment total amount
    /// - Returns: TransactionReportBuilder<TResult>
    public func withAssessmentTotalAmount(_ amount: NSDecimalNumber?) -> TransactionReportBuilder<TResult> {
        searchCriteriaBuilder.assessmentTotalAmount = amount
        return self
    }

    /// Sets the assessment description as criteria for the report for the given assessment slot (1 to 5).
    /// - Parameters:
    ///   - index: The assessment number, 1 to 5
    ///   - description: The assessment description
    /// - Returns: TransactionReportBuilder<TResult>
    public func withAssessmentDescription(_ index: Int, _ description: String?) -> TransactionReportBuilder<TResult> {
        switch index {
        case 1: searchCriteriaBuilder.assessment1Description = description
        case 2: searchCriteriaBuilder.assessment2Description = description
        case 3: searchCriteriaBuilder.assessment3Description = description
        case 4: searchCriteriaBuilder.assessment4Description = description
        case 5: searchCriteriaBuilder.assessment5Description = description
        default: break
        }
        return self
    }

    /// Sets the assessment percentage as criteria for the report for the given assessment slot (1 to 5).
    /// - Parameters:
    ///   - index: The assessment number, 1 to 5
    ///   - percentage: The assessment percentage
    /// - Returns: TransactionReportBuilder<TResult>
    public func withAssessmentPercentage(_ index: Int, _ percentage: String?) -> TransactionReportBuilder<TResult> {
        switch index {
        case 1: searchCriteriaBuilder.assessment1Percentage = percentage
        case 2: searchCriteriaBuilder.assessment2Percentage = percentage
        case 3: searchCriteriaBuilder.assessment3Percentage = percentage
        case 4: searchCriteriaBuilder.assessment4Percentage = percentage
        case 5: searchCriteriaBuilder.assessment5Percentage = percentage
        default: break
        }
        return self
    }

    /// Sets the assessment amount as criteria for the report for the given assessment slot (1 to 5).
    /// - Parameters:
    ///   - index: The assessment number, 1 to 5
    ///   - amount: The assessment amount
    /// - Returns: TransactionReportBuilder<TResult>
    public func withAssessmentAmount(_ index: Int, _ amount: NSDecimalNumber?) -> TransactionReportBuilder<TResult> {
        switch index {
        case 1: searchCriteriaBuilder.assessment1Amount = amount
        case 2: searchCriteriaBuilder.assessment2Amount = amount
        case 3: searchCriteriaBuilder.assessment3Amount = amount
        case 4: searchCriteriaBuilder.assessment4Amount = amount
        case 5: searchCriteriaBuilder.assessment5Amount = amount
        default: break
        }
        return self
    }

    /// Sets the DCC mark up percentage as criteria for the report.
    /// - Parameter percentage: The DCC mark up percentage
    /// - Returns: TransactionReportBuilder<TResult>
    public func withMarkUpDccPercentage(_ percentage: String?) -> TransactionReportBuilder<TResult> {
        searchCriteriaBuilder.markUpDccPercentage = percentage
        return self
    }

    /// Sets the multicurrency mark up percentage as criteria for the report.
    /// - Parameter percentage: The multicurrency mark up percentage
    /// - Returns: TransactionReportBuilder<TResult>
    public func withMarkUpMulticurrencyPercentage(_ percentage: String?) -> TransactionReportBuilder<TResult> {
        searchCriteriaBuilder.markUpMulticurrencyPercentage = percentage
        return self
    }

    /// Sets the fixed fee amount as criteria for the report.
    /// - Parameter amount: The fixed fee amount
    /// - Returns: TransactionReportBuilder<TResult>
    public func withFixedAmount(_ amount: NSDecimalNumber?) -> TransactionReportBuilder<TResult> {
        searchCriteriaBuilder.fixedAmount = amount
        return self
    }

    /// Sets the tax amount applied to merchant fees as criteria for the report.
    /// - Parameter amount: The fee tax amount
    /// - Returns: TransactionReportBuilder<TResult>
    public func withFeeTaxAmount(_ amount: NSDecimalNumber?) -> TransactionReportBuilder<TResult> {
        searchCriteriaBuilder.feeTaxAmount = amount
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
