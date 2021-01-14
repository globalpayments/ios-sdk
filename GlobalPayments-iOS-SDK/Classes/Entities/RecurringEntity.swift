import Foundation

/// Base interface for recurring resource types.
@objc public protocol Recurring {
    /// All resource should be supplied a merchant-/application-defined ID.
    var id: String? { get set }
    /// All resources should be supplied a gateway-defined ID.
    var key: String? { get set }
}

/// Base implementation for recurring resource types.
public class RecurringEntity<TResult>: NSObject, Recurring {
    /// All resource should be supplied a merchant-/application-defined ID.
    public var id: String?
    /// All resources should be supplied a gateway-defined ID.
    public var key: String?

    /// Creates a resource
    /// - Parameter completion: TResult
    public func create(completion: ((TResult?, Error?) -> Void)?) {
        RecurringService.create(entity: self) { recurring, error in
            if let error = error {
                completion?(nil, error)
                return
            }
            completion?((recurring as? TResult), nil)
        }
    }

    /// Delete a record from the gateway.
    public func delete() {
        RecurringService.delete(entity: self, completion: nil)
    }

    public static func find(id: String,
                            configName: String = "default",
                            completion: ((TResult?, Error?) -> Void)?) throws {
        let client = try ServicesContainer.shared.recurringClient(configName: configName)
        if client.supportsRetrieval {
            let identifier = getIdentifierName()

            let service: RecurringBuilder<[Recurring]> = RecurringService.search()
            service.addSearchCriteria(key: identifier, value: id)
                .execute { results, error in
                    if let entity = results?.first, entity.id == id {
                        RecurringService.get(entity: entity) { recurring, error in
                            if let error = error {
                                completion?(nil, error)
                                return
                            }
                            completion?((recurring as? TResult), nil)
                        }
                    } else {
                        completion?(nil, error)
                    }
            }
        }
        throw UnsupportedTransactionException(
            message: "Transaction type not supported for this payment method."
        )
    }

    /// Lists all records of type `TResult`.
    /// - Parameter completion: [TResult]
    /// - Throws: Thrown when gateway does not support retrieving recurring records.
    public static func findAll(configName: String = "default",
                               completion: (([TResult]?, Error?) -> Void)?) throws {
        let client = try ServicesContainer.shared.recurringClient(configName: configName)
        if client.supportsRetrieval {
            let service: RecurringBuilder<NSArray> = RecurringService.search()
            service.execute { results, error in
                if let error = error {
                    completion?(nil, error)
                    return
                }
                completion?((results as? [TResult]), nil)
            }
        }
        throw UnsupportedTransactionException(
            message: "Transaction type not supported for this payment method."
        )
    }
    
    private static func getIdentifierName() -> String {
        if TResult.self is Customer.Type {
            return "customerIdentifier"
        }
        if TResult.self is RecurringPaymentMethod.Type {
            return "paymentMethodIdentifier"
        }
        if TResult.self is Schedule.Type {
            return "scheduleIdentifier"
        }
        return .empty
    }
}
