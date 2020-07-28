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
    case maskedCardNumber
    case oneTime
    case paymentMethodKey
    case referenceNumber
    case settlementAmount
    case scheduleId
    case siteTrace
    case startDate
    case transactionStatus
    case uniqueDeviceId
    case username
}

public enum DataServiceCriteria: String {
    case amount
    case bankAccountNumber
    case caseId
    case cardNumberFirstSix
    case cardNumberLastFour
    case caseNumber
    case depositReference
    case endBatchDate
    case endDepositDate
    case hierarchy
    case localTransactionEndTime
    case localTransactionStartTime
    case merchantId
    case orderId
    case startBatchDate
    case startDepositDate
    case systemHierarchy
    case timezone
}

public class SearchCriteriaBuilder<TResult>: NSObject {
    private let reportBuilder: TransactionReportBuilder<TResult>

    var accountName: String?
    var accountNumberLastFour: String?
    var altPaymentStatus: String?
    var amount: Decimal?
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
    var endBatchDate: Date?
    var endDate: Date?
    var endDepositDate: Date?
    var fullyCaptured: Bool?
    var giftCurrency: String?
    var giftMaskedAlias: String?
    var hierarchy: String?
    var invoiceNumber: String?
    var issuerResult: String?
    var issuerTransactionId: String?
    var localTransactionEndTime: Date?
    var localTransactionStartTime: Date?
    var maskedCardNumber: String?
    var merchantId: String?
    var oneTime: Bool?
    var orderId: String?
    var paymentMethodKey: String?
    var paymentTypes: [PaymentMethodType]?
    var referenceNumber: String?
    var transactionType: [TransactionType]?
    var settlementAmount: Decimal?
    var scheduleId: String?
    var siteTrace: String?
    var startBatchDate: Date?
    var startDate: Date?
    var startDepositDate: Date?
    var systemHierarchy: String?
    var transactionStatus: TransactionStatus?
    var uniqueDeviceId: String?
    var username: String?
    var timezone: String?

    init(reportBuilder: TransactionReportBuilder<TResult>) {
        self.reportBuilder = reportBuilder
    }

    public func and<T>(criteria: SearchCriteria,
                       value: T) -> SearchCriteriaBuilder<TResult> {
        setValue(value, for: criteria.rawValue)
        return self
    }

    public func and<T>(criteria: DataServiceCriteria,
                       value: T) -> SearchCriteriaBuilder<TResult> {
        setValue(value, for: criteria.rawValue)
        return self
    }

    public func execute(completion: ((TResult?) -> Void)?) {
        reportBuilder.execute(completion: completion)
    }
}
