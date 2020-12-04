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
    public var lastAdjustmentFunding: AdjustmentFunding?
    public var lastAdjustmentTimeCreated: Date?
    public var documents: [DisputeDocument]?
}
