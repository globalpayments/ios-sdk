import Foundation

public class BatchService {

    /// Closes the active GPAPI batch without a batch ID, using the transaction-processing account
    /// configured in the active service configuration.
    public static func closeBatch(completion: ((BatchSummary?, Error?) -> Void)?) {
        closeBatch(configName: "default", completion: completion)
    }

    /// Closes the active GPAPI batch without a batch ID, using the transaction-processing account
    /// configured in the specified service configuration.
    public static func closeBatch(configName: String,
                                  completion: ((BatchSummary?, Error?) -> Void)?) {
        let context = resolveBatchCloseContext(configName: configName)
        closeBatch(accountName: context.accountName,
               accountId: context.accountId,
                   configName: configName,
                   completion: completion)
    }

    /// Closes the active GPAPI batch without a batch ID, scoped by currency and payment methods,
    /// using the transaction-processing account configured in the active service configuration.
    public static func closeBatch(currency: String,
                                  paymentMethods: [PaymentMethodName],
                                  completion: ((BatchSummary?, Error?) -> Void)?) {
        closeBatch(currency: currency,
                   paymentMethods: paymentMethods,
                   configName: "default",
                   completion: completion)
    }

    /// Closes the active GPAPI batch without a batch ID, scoped by currency and payment methods,
    /// using the transaction-processing account configured in the specified service configuration.
    public static func closeBatch(currency: String,
                                  paymentMethods: [PaymentMethodName],
                                  configName: String,
                                  completion: ((BatchSummary?, Error?) -> Void)?) {
        let context = resolveBatchCloseContext(configName: configName)
        closeBatch(accountName: context.accountName,
               accountId: context.accountId,
               channel: context.channel,
                   currency: currency,
               country: context.country,
                   paymentMethods: paymentMethods,
                   configName: configName,
                   completion: completion)
    }

    /// Closes a GPAPI batch identified by its batch reference.
    /// - Parameters:
    ///   - batchReference: The ID of the batch to close (e.g. "BAT_xxx").
    ///   - completion: Returns a `BatchSummary` on success, or an `Error` on failure.
    public static func closeBatch(batchReference: String?, completion: ((BatchSummary?, Error?) -> Void)?) {
        closeBatch(batchReference: batchReference, configName: "default", completion: completion)
    }

    public static func closeBatch(batchReference: String?,
                                  configName: String,
                                  completion: ((BatchSummary?, Error?) -> Void)?) {
        ManagementBuilder(transactionType: .batchClose)
            .withBatchReference(batchReference)
            .execute(configName: configName) { transaction, error in
                guard let batchSummary = transaction?.batchSummary else {
                    completion?(nil, error)
                    return
                }
                completion?(batchSummary, nil)
            }
    }

    /// Closes the active GPAPI batch for a transaction-processing account without requiring a batch ID.
   
    public static func closeBatch(accountName: String? = nil,
                                  accountId: String? = nil,
                                  channel: Channel? = nil,
                                  currency: String? = nil,
                                  country: String? = nil,
                                  paymentMethods: [PaymentMethodName]? = nil,
                                  completion: ((BatchSummary?, Error?) -> Void)?) {
        closeBatch(accountName: accountName,
                   accountId: accountId,
                   channel: channel,
                   currency: currency,
                   country: country,
                   paymentMethods: paymentMethods,
                   configName: "default",
                   completion: completion)
    }

    public static func closeBatch(accountName: String? = nil,
                                  accountId: String? = nil,
                                  channel: Channel? = nil,
                                  currency: String? = nil,
                                  country: String? = nil,
                                  paymentMethods: [PaymentMethodName]? = nil,
                                  configName: String,
                                  completion: ((BatchSummary?, Error?) -> Void)?) {
        ManagementBuilder(transactionType: .batchClose)
            .withAccountName(accountName)
            .withAccountId(accountId)
            .withChannel(channel)
            .withCurrency(currency)
            .withCountry(country)
            .withPaymentMethods(paymentMethods)
            .execute(configName: configName) { transaction, error in
                guard let batchSummary = transaction?.batchSummary else {
                    completion?(nil, error)
                    return
                }
                completion?(batchSummary, nil)
            }
    }

    private static func resolveBatchCloseContext(configName: String) -> (
        accountName: String?,
        accountId: String?,
        channel: Channel?,
        country: String?
    ) {
        guard let connector = try? ServicesContainer.shared.client(configName: configName) as? GpApiConnector else {
            return (nil, nil, nil, nil)
        }

        let accessTokenInfo = connector.gpApiConfig.accessTokenInfo
        return (
            accessTokenInfo?.transactionProcessingAccountName,
            accessTokenInfo?.transactionProcessingAccountID,
            connector.gpApiConfig.channel,
            connector.gpApiConfig.country
        )
    }
}
