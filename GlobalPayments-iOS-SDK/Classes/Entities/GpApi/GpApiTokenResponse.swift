import Foundation

class GpApiTokenResponse {
    let DATA_ACCOUNT_NAME_PREFIX = "DAA_"
    let DISPUTE_MANAGEMENT_ACCOUNT_NAME_PREFIX = "DIA_"
    let TOKENIZATION_ACCOUNT_NAME_PREFIX = "TKA_"
    let TRANSACTION_PROCESSING_ACCOUNT_NAME_PREFIX = "TRA_"
    let RIKS_ASSESSMENT_ACCOUNT_NAME_PREFIX = "RAA_"
    let FILE_PROCESSING_ACCOUNT_NAME_PREFIX = "FPA_"
    
    var token: String?
    var type: String?
    var appId: String?
    var appName: String?
    var timeCreated: Date?
    var secondsToExpire: Int?
    var email: String?
    var merchantId: String?
    var merchantName: String?
    var accounts = [GpApiAccount]()
    
    var dataAccountName: String? {
        return accountName(with: DATA_ACCOUNT_NAME_PREFIX)
    }
    var disputeManagementAccountName: String? {
        return accountName(with: DISPUTE_MANAGEMENT_ACCOUNT_NAME_PREFIX)
    }
    var tokenizationAccountName: String? {
        return accountName(with: TOKENIZATION_ACCOUNT_NAME_PREFIX)
    }
    var transactionProcessingAccountName: String? {
        return accountName(with: TRANSACTION_PROCESSING_ACCOUNT_NAME_PREFIX)
    }
    var riskAssessmentAccountName: String? {
        return accountName(with: RIKS_ASSESSMENT_ACCOUNT_NAME_PREFIX)
    }
    var fileProcessingAccountName: String? {
        return accountName(with: FILE_PROCESSING_ACCOUNT_NAME_PREFIX)
    }
    
    var dataAccountID: String? {
        return getAccountID(with: DATA_ACCOUNT_NAME_PREFIX)
    }
    var disputeManagementAccountID: String? {
        return getAccountID(with: DISPUTE_MANAGEMENT_ACCOUNT_NAME_PREFIX)
    }
    var tokenizationAccountID: String? {
        return getAccountID(with: TOKENIZATION_ACCOUNT_NAME_PREFIX)
    }
    var TransactionProcessingAccountID: String? {
        return getAccountID(with: TRANSACTION_PROCESSING_ACCOUNT_NAME_PREFIX)
    }
    var riskAssessmentAccountID: String? {
        return getAccountID(with: RIKS_ASSESSMENT_ACCOUNT_NAME_PREFIX)
    }
    var fileProcessingAccountID: String? {
        return getAccountID(with: FILE_PROCESSING_ACCOUNT_NAME_PREFIX)
    }

    init(_ jsonString: String) {
        let doc = JsonDoc.parse(jsonString)
        mapResponseValues(doc)
    }

    func mapResponseValues(_ doc: JsonDoc?) {
        token = doc?.getValue(key: "token")
        type = doc?.getValue(key: "type")
        appId = doc?.getValue(key: "app_id")
        appName = doc?.getValue(key: "app_name")
        if let createdTime: String = doc?.getValue(key: "time_created") {
            timeCreated = createdTime.format()
        }
        secondsToExpire = doc?.getValue(key: "seconds_to_expire")
        email = doc?.getValue(key: "email")
        if let doc = doc, doc.has(key: "scope") {
            let scope = doc.get(valueFor: "scope")
            merchantId = scope?.getValue(key: "merchant_id")
            merchantName = scope?.getValue(key: "merchant_name")
            if let scope = scope, scope.has(key: "accounts"),
                let accounts = scope.getEnumerator(key: "accounts") {
                self.accounts = accounts.map {
                    GpApiAccount(
                        id: $0.getValue(key: "id"),
                        name: $0.getValue(key: "name"),
                        permissions: $0.getValue(key: "permissions")
                    )
                }
            }
        }
    }
    
    private func  getAccountID(with prefix: String) -> String {
        return accounts.first(where: { ($0.id ?? .empty).hasPrefix(prefix) })?.id ?? .empty
    }

    private func accountName(with prefix: String) -> String? {
        return accounts.first(where: { ($0.id ?? .empty).hasPrefix(prefix) })?.name
    }
}
