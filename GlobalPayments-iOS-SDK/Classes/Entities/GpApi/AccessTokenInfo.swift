import Foundation

public class AccessTokenInfo {
    public var token: String?
    public var dataAccountName: String?
    public var disputeManagementAccountName: String?
    public var tokenizationAccountName: String?
    public var transactionProcessingAccountName: String?
    public var riskAssessmentAccountName: String?
    public var dataAccountID: String?
    public var disputeManagementAccountID: String?
    public var tokenizationAccountID: String?
    public var transactionProcessingAccountID: String?
    public var riskAssessmentAccountID: String?
    public var fileProcessingAccountID: String?
    public var fileProcessingAccountName: String?
    
    public init(token: String? = nil,
                dataAccountName: String? = nil,
                disputeManagementAccountName: String? = nil,
                tokenizationAccountName: String? = nil,
                transactionProcessingAccountName: String? = nil,
                transactionProcessingAccountID: String? = nil,
                fileProcessingAccountID: String? = nil,
                fileProcessingAccountName: String? = nil) {
        
        self.token = token
        self.dataAccountName = dataAccountName
        self.disputeManagementAccountName = disputeManagementAccountName
        self.tokenizationAccountName = tokenizationAccountName
        self.transactionProcessingAccountName = transactionProcessingAccountName
        self.transactionProcessingAccountID = transactionProcessingAccountID
        self.fileProcessingAccountID = fileProcessingAccountID
        self.fileProcessingAccountName = fileProcessingAccountName
    }
}
