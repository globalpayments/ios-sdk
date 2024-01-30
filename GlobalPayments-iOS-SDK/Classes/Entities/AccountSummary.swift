import Foundation

public class AccountSummary {
    public var id: String?
    public var type: String?
    public var name: String?
    public var status: UserStatus?
    public var permissions: [String]?
    public var countries: [String]?
    public var currencies: [String]?
    public var channels: String?
    public var paymentMethods: String?
    public var email: String?
}

extension AccountSummary: JsonToObject {
    
    public static func mapToObject<T>(_ doc: JsonDoc) -> T? {
        let accountSummary = AccountSummary()
        accountSummary.id = doc.getValue(key: "id")
        accountSummary.type = doc.getValue(key: "type")
        accountSummary.name = doc.getValue(key: "name")
        accountSummary.channels = doc.getValue(key: "channels")
        accountSummary.paymentMethods = doc.getValue(key: "payment_methods")
        accountSummary.permissions = doc.getValue(key: "permissions")
        accountSummary.countries = doc.getValue(key: "countries")
        accountSummary.currencies = doc.getValue(key: "currencies")
        accountSummary.email = doc.getValue(key: "email_id")
        if let status: String = doc.getValue(key: "status") {
            accountSummary.status = UserStatus(rawValue: status)
        }
        return accountSummary as? T
    }
}

