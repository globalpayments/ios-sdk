import Foundation

 public class RecurringBuilder<TResult>: TransactionBuilder<TResult> {

    var key: String?
    var orderId: String?
    var entity: Recurring?
    var searchCriteria: [String: String]?
    /// Masking of personally identifiable fields on fetch (`masked` query parameter).
    var masked: Bool?

    init(type: TransactionType, entity: Recurring? = nil) {
        super.init(transactionType: type)
        self.searchCriteria = [String: String]()
        if entity != nil {
            self.entity = entity
            self.key = entity?.key ?? entity?.id
        }
    }

    public func addSearchCriteria(key: String, value: String) -> RecurringBuilder {
        searchCriteria?[key] = value
        return self
    }

    /// Sets whether personally identifiable fields are masked in the response (GET payer).
    public func withMasked(_ masked: Bool?) -> RecurringBuilder {
        self.masked = masked
        return self
    }

    /// Executes the builder against the gateway.
    public override func execute(configName: String = "default",
                                 completion: ((TResult?, Error?) -> Void)?) {

        super.execute(configName: configName) { _, error in
            if let error = error {
                completion?(nil, error)
                return
            }
            do {
                let client = try ServicesContainer.shared.recurringClient(configName: configName)
                client.processRecurring(builder: self, completion: { result, error  in
                    completion?(result, error)
                })
            } catch {
                completion?(nil, error)
            }
        }
    }

    public override func setupValidations() {
        self.validations
            .of(transactionType: [.edit, .delete, .fetch])
            .check(propertyName: "key")?.isNotNil()

        self.validations
            .of(transactionType: [.search])
            .check(propertyName: "searchCriteria")?.isNotNil()
    }
}
