import Foundation

public class DisputeSummary {
    public var merchantHierarchy: String?
    public var merchantName: String?
    public var merchantDbaName: String?
    public var merchantNumber: String?
    public var merchantCategory: String?
    public var depositDate: Date?
    public var depositReference: String?
    public var depositType: String?
    public var type: String?
    public var caseAmount: NSDecimalNumber?
    public var caseCurrency: String?
    public var caseStatus: String?
    public var caseDescription: String?
    public var caseStage: DisputeStage?
    public var caseStageTime: Date?
    public var transactionOrderId: String?
    public var transactionLocalTime: Date?
    public var transactionTime: Date?
    public var transactionType: String?
    public var transactionAmount: NSDecimalNumber?
    public var transactionCurrency: String?
    public var caseNumber: String?
    public var caseTime: Date?
    public var caseId: String?
    public var caseIdTime: Date?
    public var caseMerchantId: String?
    public var caseTerminalId: String?
    public var transactionARN: String?
    /// The unique reference created by the brands/schemes to identify the disputed transaction.
    public var transactionBrandReference: String?
    public var transactionId: String?
    public var transactionReferenceNumber: String?
    public var transactionSRD: String?
    public var transactionAuthCode: String?
    public var transactionCardType: String?
    public var transactionMaskedCardNumber: String?
    public var reason: String?
    public var reasonCode: String?
    public var result: String?
    public var issuerComment: String?
    public var issuerCaseNumber: String?
    public var disputeAmount: NSDecimalNumber?
    public var disputeCurrency: String?
    public var disputeCustomerAmount: NSDecimalNumber?
    public var disputeCustomerCurrency: String?
    public var respondByDate: Date?
    public var caseOriginalReference: String?
    public var lastAdjustmentAmount: NSDecimalNumber?
    public var lastAdjustmentCurrency: String?
    public var lastAdjustmentFunding: String?
    public var lastAdjustmentTimeCreated: Date?
    public var documents: [DisputeDocument]?
    /// Merchant identifier set by Global Payments (`merchant_id`).
    public var merchantId: String?
    /// Merchant label set by Global Payments (top level `merchant_name`). `merchantName` holds `system.name`.
    public var merchantLabel: String?
    public var accountId: String?
    public var accountName: String?
    public var caseStatusTime: Date?
    public var investigatorComment: String?
    public var acquirerCode: String?
    public var globalTransactionReference: String?
    public var globalTransactionSource: String?
    public var netFinancialAmount: NSDecimalNumber?
    public var netFinancialCurrency: String?
    public var netFinancialFunding: String?
    public var foreignIssuedCard: String?
    public var dispositionDescription: String?
    public var dispositionDate: Date?
    public var storeReference: String?
    public var regionCode: String?
    public var paymentMethodProviders: [DisputePaymentMethodProvider]?
    public var transactionRemarks: String?
    public var terminalCapabilityCode: String?
    public var avsResult: String?
    public var entryModeCode: String?
    public var cardBrandReference: String?
    public var cardIssuerBin: String?
    public var cardAcquirerBin: String?
    public var orderInvoiceNumber: String?
    public var terminalCapacityCode: String?
    /// Details of the action executed (id, type, time created, result code, app id and app name).
    public var action: ActionSummary?
}

/// Data associated with the payment method provider for a Dispute.
public class DisputePaymentMethodProvider {
    public var comment: String?
    public var reference: String?
    public var documents: [DisputeDocument]?
}
