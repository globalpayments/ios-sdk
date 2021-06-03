import Foundation

public enum SearchCriteria: String {
    case accountName
    case accountNumberLastFour
    case altPaymentStatus
    case aquirerReferenceNumber
    case authCode
    case bankRoutingNumber
    case batchId
    case batchSequenceNumber
    case brandReference
    case buyerEmailAddress
    case cardBrand
    case cardHolderFirstName
    case cardHolderLastName
    case cardHolderPoNumber
    case cardNumberFirstSix
    case cardNumberLastFour
    case checkFirstName
    case checkLastName
    case checkName
    case checkNumber
    case clerkId
    case clientTransactionId
    case customerId
    case displayName
    case endDate
    case fullyCaptured
    case giftCurrency
    case giftMaskedAlias
    case invoiceNumber
    case issuerResult
    case issuerTransactionId
    case oneTime
    case paymentMethodKey
    case referenceNumber
    case settlementAmount
    case scheduleId
    case siteTrace
    case startDate
    case disputeReference
    case settlementDisputeId
    case disputeDocumentReference
    case uniqueDeviceId
    case username
    case name
    case tokenFirstSix
    case tokenLastFour
    case accountId
    case actionType
    case appName
    case httpResponseCode
    case merchantName
    case resource
    case resourceStatus
    case resourceId
    case responseCode
    case version
    case actionId
}

public enum DataServiceCriteria: String {
    case amount
    case bankAccountNumber
    case caseId
    case caseNumber
    case depositReference
    case endDepositDate
    case endStageDate
    case hierarchy
    case localTransactionEndTime
    case localTransactionStartTime
    case merchantId
    case orderId
    case startDepositDate
    case startStageDate
    case systemHierarchy
    case timezone
    case country
    case currency
    case startBatchDate
    case endBatchDate
    case storedPaymentMethodId
    case startLastUpdatedDate
    case endLastUpdatedDate
}

@objcMembers public class SearchCriteriaBuilder<TResult>: NSObject {
    private weak var reportBuilder: TransactionReportBuilder<TResult>?

    var accountName: String?
    var accountNumberLastFour: String?
    var altPaymentStatus: String?
    var amount: NSDecimalNumber?
    var aquirerReferenceNumber: String?
    var authCode: String?
    var bankAccountNumber: String?
    var bankRoutingNumber: String?
    var batchId: String?
    var batchSequenceNumber: String?
    var brandReference: String?
    var buyerEmailAddress: String?
    var cardBrand: String?
    var cardHolderFirstName: String?
    var cardHolderLastName: String?
    var cardHolderPoNumber: String?
    var cardNumberFirstSix: String?
    var cardNumberLastFour: String?
    var caseId: String?
    var caseNumber: String?
    var cardTypes: [CardType]?
    var checkFirstName: String?
    var checkLastName: String?
    var checkName: String?
    var checkNumber: String?
    var clerkId: String?
    var clientTransactionId: String?
    var customerId: String?
    var depositReference: String?
    var displayName: String?
    var disputeReference: String?
    var disputeStage: DisputeStage?
    var disputeStatus: DisputeStatus?
    var disputeDocumentReference: String?
    var endBatchDate: Date?
    var endDate: Date?
    var endDepositDate: Date?
    var endStageDate: Date?
    var fullyCaptured: Bool?
    var giftCurrency: String?
    var giftMaskedAlias: String?
    var hierarchy: String?
    var invoiceNumber: String?
    var issuerResult: String?
    var issuerTransactionId: String?
    var localTransactionEndTime: Date?
    var localTransactionStartTime: Date?
    var merchantId: String?
    var oneTime: Bool?
    var orderId: String?
    var paymentMethodKey: String?
    var paymentTypes: [PaymentMethodType]?
    var referenceNumber: String?
    var transactionType: [TransactionType]?
    var settlementAmount: NSDecimalNumber?
    var settlementDisputeId: String?
    var scheduleId: String?
    var siteTrace: String?
    var startBatchDate: Date?
    var startDate: Date?
    var startDepositDate: Date?
    var startStageDate: Date?
    var systemHierarchy: String?
    var transactionStatus: TransactionStatus?
    var uniqueDeviceId: String?
    var username: String?
    var timezone: String?
    var depositStatus: DepositStatus?
    var channel: Channel?
    var currency: String?
    var country: String?
    var paymentEntryMode: PaymentEntryMode?
    var name: String?
    var paymentType: PaymentType?
    var tokenFirstSix: String?
    var tokenLastFour: String?
    var storedPaymentMethodId: String?
    var storedPaymentMethodStatus: StoredPaymentMethodStatus?
    var startLastUpdatedDate: Date?
    var endLastUpdatedDate: Date?
    var accountId: String?
    var actionType: String?
    var appName: String?
    var httpResponseCode: String?
    var merchantName: String?
    var resource: String?
    var resourceStatus: String?
    var resourceId: String?
    var responseCode: String?
    var version: String?
    var actionId: String?

    init(reportBuilder: TransactionReportBuilder<TResult>?) {
        self.reportBuilder = reportBuilder
    }

    public func and<T>(searchCriteria: SearchCriteria, value: T) -> SearchCriteriaBuilder<TResult> {
        setValue(value, for: searchCriteria.rawValue)
        return self
    }

    public func and<T>(dataServiceCriteria: DataServiceCriteria, value: T) -> SearchCriteriaBuilder<TResult> {
        setValue(value, for: dataServiceCriteria.rawValue)
        return self
    }

    public func and(transactionStatus: TransactionStatus?) -> SearchCriteriaBuilder<TResult> {
        self.transactionStatus = transactionStatus
        return self
    }

    public func and(disputeStage: DisputeStage?) -> SearchCriteriaBuilder<TResult> {
        self.disputeStage = disputeStage
        return self
    }

    public func and(disputeStatus: DisputeStatus?) -> SearchCriteriaBuilder<TResult> {
        self.disputeStatus = disputeStatus
        return self
    }

    public func and(depositStatus: DepositStatus?) -> SearchCriteriaBuilder<TResult> {
        self.depositStatus = depositStatus
        return self
    }

    public func and(channel: Channel?) -> SearchCriteriaBuilder<TResult> {
        self.channel = channel
        return self
    }

    public func and(paymentEntryMode: PaymentEntryMode?) -> SearchCriteriaBuilder<TResult> {
        self.paymentEntryMode = paymentEntryMode
        return self
    }

    public func and(paymentType: PaymentType?) -> SearchCriteriaBuilder<TResult> {
        self.paymentType = paymentType
        return self
    }

    public func and(storedPaymentMethodStatus: StoredPaymentMethodStatus?) -> SearchCriteriaBuilder<TResult> {
        self.storedPaymentMethodStatus = storedPaymentMethodStatus
        return self
    }

    public func execute(completion: ((TResult?, Error?) -> Void)?) {
        reportBuilder?.execute(completion: completion)
    }
}
