import Foundation

class GpApiTokenResponse {
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
        return accountName(with: "DAA_")
    }
    var disputeManagementAccountName: String? {
        return accountName(with: "DIA_")
    }
    var tokenizationAccountName: String? {
        return accountName(with: "TKA_")
    }
    var transactionProcessingAccountName: String? {
        return accountName(with: "TRA_")
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

    private func accountName(with prefix: String) -> String? {
        return accounts.first(where: { ($0.id ?? .empty).hasPrefix(prefix) })?.name
    }
}
