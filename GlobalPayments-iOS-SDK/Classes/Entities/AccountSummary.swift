import Foundation

public class AccountSummary {
    public var id: String?
    public var type: MerchantAccountType?
    public var name: String?
    public var status: UserStatus?
    public var permissions: [String]?
    public var countries: [String]?
    public var currencies: [String]?
    public var channels: [Channel]?
    public var paymentMethods: [AccountPaymentMethod]?
    public var email: String?
    /// A list of configurations for an account. Each configuration's countries, channels, currencies and payment_methods represents a different transaction processing system route.
    public var configurations: [TransactionProcessingConfiguration]?
    public var action: ActionSummary?
    public var timeCreated: Date?
    public var timeLastUpdated: Date?
    public var merchantId: String?
    public var merchantName: String?
    /// Reason a prepaid card was replaced. Present on PATCH /accounts/{id} responses.
    public var cardReplacementReason: CardReplacementReason?
    /// Capabilities enabled/disabled on a Funds Management Account.
    public var capabilities: [AccountCapability]?
    public var paymentProcessingStatistics: AccountPaymentProcessingStatistics?
}

extension AccountSummary: JsonToObject {
    
    public static func mapToObject<T>(_ doc: JsonDoc) -> T? {
        let accountSummary = AccountSummary()
        accountSummary.id = doc.getValue(key: "id")
        accountSummary.name = doc.getValue(key: "name")
        accountSummary.permissions = doc.getValue(key: "permissions")
        accountSummary.countries = doc.getValue(key: "countries")
        accountSummary.currencies = doc.getValue(key: "currencies")
        accountSummary.email = doc.getValue(key: "email_id")
        accountSummary.merchantId = doc.getValue(key: "merchant_id")
        accountSummary.merchantName = doc.getValue(key: "merchant_name")
        let timeCreated: String? = doc.getValue(key: "time_created")
        accountSummary.timeCreated = timeCreated?.format()
        let timeLastUpdated: String? = doc.getValue(key: "time_last_updated")
        accountSummary.timeLastUpdated = timeLastUpdated?.format()
        if let cardReplacementReason: String = doc.getValue(keys: "card_replacment_reason", "card_replacement_reason") {
            accountSummary.cardReplacementReason = CardReplacementReason(rawValue: cardReplacementReason)
        }
        if let type: String = doc.getValue(key: "type") {
            accountSummary.type = MerchantAccountType(rawValue: type)
        }
        if let status: String = doc.getValue(key: "status") {
            accountSummary.status = UserStatus(rawValue: status)
        }
        if let channels: [String] = doc.getValue(key: "channels") {
            accountSummary.channels = channels.compactMap { Channel(value: $0) }
        }
        if let paymentMethods: [String] = doc.getValue(key: "payment_methods") {
            accountSummary.paymentMethods = paymentMethods.compactMap { AccountPaymentMethod(value: $0) }
        }
        if let configurations: [JsonDoc] = doc.getValue(key: "configurations") {
            accountSummary.configurations = configurations.map { TransactionProcessingConfiguration.mapToObject($0)! }
        }
        if let capabilities: [String] = doc.getValue(key: "capabilities") {
            accountSummary.capabilities = capabilities.compactMap { AccountCapability(rawValue: $0) }
        }
        if let statistics = doc.get(valueFor: "payment_processing_statistics") {
            accountSummary.paymentProcessingStatistics = AccountPaymentProcessingStatistics.mapToObject(statistics)
        }
        if let action = doc.get(valueFor: "action") {
            accountSummary.action = GpApiMapping.mapActionSummary(action)
        }
        return accountSummary as? T
    }
}

