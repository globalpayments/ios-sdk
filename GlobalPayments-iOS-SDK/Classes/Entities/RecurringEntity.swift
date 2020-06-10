import Foundation

/// Base interface for recurring resource types.
@objc public protocol Recurring {
    /// Creates a resource
    func create() -> Any?
    /// Delete a record from the gateway.
    func delete() -> Any?
    /// Searches for a specific record by `id`.
    /// - Parameter id: The ID of the record to find
    /// - Returns: If the record cannot be found, `null` is returned.
    func find(id: String) -> Any?
    /// Lists all records of type `TResult`.
    func findAll() -> [Any]?
    /// The current record should be updated.
    /// Any modified properties will be persisted with the gateway.
    func saveChanges() -> Any?
}

@objcMembers public class RecurringEntity: NSObject, Recurring {

    /// All resource should be supplied a merchant-/application-defined ID.
    var id: String?
    /// All resources should be supplied a gateway-defined ID.
    var key: String?

    public func create() -> Any? {
        return RecurringService.create(entity: self)
    }

    public func delete() -> Any? {
        return RecurringService.delete(entity: self)
    }

    public func find(id: String) -> Any? {
        let client = ServicesContainer.shared.getRecurringClient()
        if let supportsRetrieval = client?.supportsRetrieval,
            supportsRetrieval == true {
            let identifier = getIdentifierName()
            let entity = RecurringService.search(entity: self)
                .addSearchCriteria(key: identifier, value: id)
                .execute() as? RecurringEntity
            if entity != nil, entity?.id == id {
                return RecurringService.get(entity: entity!)
            }
            return nil
        }
        return nil
    }

    public func findAll() -> [Any]? {
        let client = ServicesContainer.shared.getRecurringClient()
        guard let supportsRetrieval = client?.supportsRetrieval,
            supportsRetrieval == false else {
            return nil
        }
        let response = RecurringService
            .search(entity: self)
            .execute()

        return [response]
    }

    public func saveChanges() -> Any? {
        return RecurringService.edit(entity: self)
    }

    private func getIdentifierName() -> String {
        if self is Customer {
            return "customerIdentifier"
        }
        if self is RecurringPaymentMethod {
            return "paymentMethodIdentifier"
        }
        if self is Schedule {
            return "scheduleIdentifier"
        }
        return .empty
    }
}
