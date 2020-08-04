import Foundation

public class RecurringBuilder<TResult>: TransactionBuilder<TResult> {

    var key: String?
    var orderId: String?
    var entity: Recurring?
    var searchCriteria: [String: String]?

    init(type: TransactionType, entity: Recurring? = nil) {
        super.init(transactionType: type)
        self.searchCriteria = [String: String]()
        if entity != nil {
            self.entity = entity
            self.key = entity?.key
        }
    }

    public func addSearchCriteria(key: String, value: String) -> RecurringBuilder {
        searchCriteria?[key] = value
        return self
    }

    /// Executes the builder against the gateway.
    public override func execute(configName: String = "default",
                                 completion: ((TResult?, Error?) -> Void)?) {
        super.execute(configName: configName, completion: nil)
        do {
            let client = try ServicesContainer.shared.recurringClient(configName: configName)
            client.processRecurring(builder: self, completion: { result in
                completion?(result, nil)
            })
        } catch {
            completion?(nil, error)
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
