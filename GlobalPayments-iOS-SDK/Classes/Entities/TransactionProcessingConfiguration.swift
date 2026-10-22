import Foundation

/// A configuration's countries, channels, currencies and payment_methods represents a different transaction processing system route.
public class TransactionProcessingConfiguration {
    public var countries: [String]?
    public var currencies: [String]?
    public var channels: [Channel]?
    public var paymentMethods: [AccountPaymentMethod]?
}

extension TransactionProcessingConfiguration: JsonToObject {

    public static func mapToObject<T>(_ doc: JsonDoc) -> T? {
        let configuration = TransactionProcessingConfiguration()
        configuration.countries = doc.getValue(key: "countries")
        configuration.currencies = doc.getValue(key: "currencies")
        if let channels: [String] = doc.getValue(key: "channels") {
            configuration.channels = channels.compactMap { Channel(value: $0) }
        }
        if let paymentMethods: [String] = doc.getValue(key: "payment_methods") {
            configuration.paymentMethods = paymentMethods.compactMap { AccountPaymentMethod(value: $0) }
        }
        return configuration as? T
    }
}
