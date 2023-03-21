import Foundation

public class AccessTokenInfo {
    public var token: String?
    public var dataAccountName: String?
    public var disputeManagementAccountName: String?
    public var tokenizationAccountName: String?
    public var transactionProcessingAccountName: String?

    public init(token: String? = nil,
                dataAccountName: String? = nil,
                disputeManagementAccountName: String? = nil,
                tokenizationAccountName: String? = nil,
                transactionProcessingAccountName: String? = nil) {

        self.token = token
        self.dataAccountName = dataAccountName
        self.disputeManagementAccountName = disputeManagementAccountName
        self.tokenizationAccountName = tokenizationAccountName
        self.transactionProcessingAccountName = transactionProcessingAccountName
    }
}
