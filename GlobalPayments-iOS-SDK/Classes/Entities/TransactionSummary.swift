import Foundation

/// Transaction-level report data
public class TransactionSummary {
    public var accountDataSource: String?
    public var adjustmentAmount: Decimal?
    public var adjustmentCurrency: String?
    public var adjustmentReason: String?
    public var altPaymentData: AltPaymentData?
    /// The originally requested authorization amount.
    public var amount: Decimal?
    public var aquirerReferenceNumber: String?
    /// The authorized amount.
    public var authorizedAmount: Decimal?
    /// The authorization code provided by the issuer.
    public var authCode: String?
    public var batchCloseDate: Date?
    public var batchSequenceNumber: String?
    public var billingAddress: Address?
    public var captureAmount: Decimal?
    public var cardHolderFirstName: String?
    public var cardHolderLastName: String?
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
    public var convenienceAmount: Decimal?
    public var currency: String?
    public var customerFirstName: String?
    public var customerId: String?
    public var customerLastName: String?
    public var debtRepaymentIndicator: Bool?
    public var depositAmount: Decimal?
    public var depositCurrency: String?
    public var depositDate: Date?
    public var depositReference: String?
    public var depositType: String?
    public var description: String?
    /// The device ID where the transaction was ran, where applicable.
    public var deviceId: Int?
    public var emvChipCondition: String?
    public var entryMode: String?
    public var fraudRuleInfo: String?
    public var fullyCaptured: Bool?
    public var cashBackAmount: Decimal?
    public var gratuityAmount: Decimal?
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
}

//    /// <summary>
//    /// The settled from the authorization.
//    /// </summary>
//    public decimal? SettlementAmount { get; set; }
//
//    /// <summary>
//    /// The originally requested shipping amount.
//    /// </summary>
//    public decimal? ShippingAmount { get; set; }
//
//    public string SiteTrace { get; set; }
//
//    /// <summary>
//    /// The transaction status.
//    /// </summary>
//    public string Status { get; set; }
//
//    public decimal? SurchargeAmount { get; set; }
//
//    public decimal? TaxAmount { get; set; }
//
//    public string TaxType { get; set; }
//
//    public string TerminalId { get; set; }
//
//    public string TokenPanLastFour { get; set; }
//
//    /// <summary>
//    /// The date/time of the original transaction.
//    /// </summary>
//    public DateTime? TransactionDate { get; set; }
//
//    public DateTime? TransactionLocalDate { get; set; }
//
//    public string TransactionDescriptor { get; set; }
//
//    public string TransactionStatus { get; set; }
//
//    /// <summary>
//    /// The gateway transaction ID of the transaction.
//    /// </summary>
//    public string TransactionId { get; set; }
//
//    public string UniqueDeviceId { get; set; }
//
//    public string Username { get; set; }
//
//    public string TransactionType { get; set; }
//
//    public string CardEntryMethod { get; set; }
//
//    public decimal? AmountDue { get; set; }
//
//    public bool HostTimeout { get; set; }
//
//    public string Country { get; set; }
