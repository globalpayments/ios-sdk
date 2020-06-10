import Foundation

@objcMembers public class RecurringBuilder: TransactionBuilder {

    var key: String?
    var orderId: String?
    var entity: RecurringEntity?
    var searchCriteria: [String: String]?

    public init(type: TransactionType, entity: RecurringEntity? = nil) {
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

    public override func execute() -> Any? {
        super.execute()
        let client = ServicesContainer.shared.recurring
        return client?.processRecurring(builder: self)
    }

    public override func setupValidations() {
        self.validations
            .of(transactionType: [.edit, .delete, .fetch])
            .check(propertyName: "key")?
            .isNotNil()

        self.validations
            .of(transactionType: [.search])
            .check(propertyName: "searchCriteria")?
            .isNotNil()
    }
}
