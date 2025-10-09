import Foundation

/// Transaction-level report data
public class TransactionSummary {
    public var alternativePaymentResponse: AlternativePaymentResponse?
    public var accountDataSource: String?
    public var adjustmentAmount: NSDecimalNumber?
    public var adjustmentCurrency: String?
    public var adjustmentReason: String?
    public var altPaymentData: AltPaymentData?
    /// The originally requested authorization amount.
    public var amount: NSDecimalNumber?
    public var aquirerReferenceNumber: String?
    /// The authorized amount.
    public var authorizedAmount: NSDecimalNumber?
    /// The authorization code provided by the issuer.
    public var authCode: String?
    public var batchCloseDate: Date?
    public var batchSequenceNumber: String?
    public var billingAddress: Address?
    public var brandReference: String?
    public var captureAmount: NSDecimalNumber?
    public var cardHolderFirstName: String?
    public var cardHolderLastName: String?
    public var cardHolderName: String?
    public var cardSwiped: String?
    public var cardType: String?
    public var cavvResponseCode: String?
    public var channel: String?
    public var checkData: CheckData?
    public var clerkId: String?
    /// The client transaction ID sent in the authorization request.
    public var clientTransactionId: String?
    public var companyName: String?
    /// The originally requested convenience amount.
    public var convenienceAmount: NSDecimalNumber?
    public var currency: String?
    public var customerFirstName: String?
    public var customerId: String?
    public var customerLastName: String?
    public var debtRepaymentIndicator: Bool?
    public var depositAmount: NSDecimalNumber?
    public var depositCurrency: String?
    public var depositDate: Date?
    public var depositReference: String?
    public var depositType: String?
    public var depositStatus: DepositStatus?
    public var description: String?
    /// The device ID where the transaction was ran, where applicable.
    public var deviceId: Int?
    public var emvChipCondition: String?
    public var entryMode: String?
    public var fraudRuleInfo: String?
    public var fullyCaptured: Bool?
    public var cashBackAmount: NSDecimalNumber?
    public var gratuityAmount: NSDecimalNumber?
    public var hasEcomPaymentData: Bool?
    public var hasEmvTags: Bool?
    public var invoiceNumber: String?
    /// The original response code from the issuer.
    public var issuerResponseCode: String?
    /// The original response message from the issuer.
    public var issuerResponseMessage: String?
    public var issuerTransactionId: String?
    /// The original response code from the gateway.
    public var gatewayResponseCode: String?
    /// The original response message from the gateway.
    public var gatewayResponseMessage: String?
    public var giftCurrency: String?
    public var lodgingData: LodgingData?
    public var maskedAlias: String?
    /// The authorized card number, masked.
    public var maskedCardNumber: String?
    public var merchantCategory: String?
    public var merchantDbaName: String?
    public var merchantHierarchy: String?
    public var merchantId: String?
    public var merchantDeviceIdentifier: String?
    public var merchantName: String?
    public var merchantNumber: String?
    public var oneTimePayment: Bool?
    public var orderId: String?
    /// The gateway transaction ID of the authorization request.
    public var originalTransactionId: String?
    public var paymentMethodKey: String?
    public var paymentType: String?
    public var poNumber: String?
    public var recurringDataCode: String?
    /// The reference number provided by the issuer.
    public var referenceNumber: String?
    public var repeatCount: Int?
    public var responseDate: Date?
    public var scheduleId: String?
    public var schemeReferenceData: String?
    /// The transaction type.
    public var serviceName: String?
    /// The settled from the authorization.
    public var settlementAmount: NSDecimalNumber?
    /// The originally requested shipping amount.
    public var shippingAmount: NSDecimalNumber?
    public var siteTrace: String?
    /// The transaction status.
    public var status: String?
    public var surchargeAmount: NSDecimalNumber?
    public var taxAmount: NSDecimalNumber?
    public var taxType: String?
    public var terminalId: String?
    public var tokenPanLastFour: String?
    /// The date/time of the original transaction.
    public var transactionDate: Date?
    public var transactionLocalDate: Date?
    public var transactionDescriptor: String?
    public var transactionStatus: TransactionStatus?
    /// The gateway transaction ID of the transaction.
    public var transactionId: String?
    public var uniqueDeviceId: String?
    public var username: String?
    public var transactionType: String?
    public var cardEntryMethod: String?
    public var amountDue: NSDecimalNumber?
    public var hostTimeout: Bool?
    public var country: String?
    public var fingerprint: String?
    public var fingerprintIndicator: String?
    public var bnplResponse: BNPLResponse?
    public var bankPaymentResponse: BankPaymentResponse?
    
    /// Card details
    public var cardDetails: Card?
    public var threeDSecure: ThreeDSecure?
    public var installmentData: InstallmentData?
}
