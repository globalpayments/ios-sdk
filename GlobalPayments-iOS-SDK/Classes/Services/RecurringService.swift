import Foundation

public class RecurringService {

    public static func create<T: Recurring>(entity: T?,
                                            completion: ((T?) -> Void)?) {
        let response = RecurringBuilder<T>(type: .create, entity: entity)
        response.execute(completion: completion)
    }

    public static func delete<T: Recurring>(entity: T?,
                                            completion: ((T?) -> Void)?) {
        let response = RecurringBuilder<T>(type: .delete, entity: entity)
        response.execute(completion: completion)
    }

    public static func edit<T: Recurring>(entity: T?,
                                          completion: ((T?) -> Void)?) {
        let response = RecurringBuilder<T>(type: .delete, entity: entity)
        response.execute(completion: completion)
    }

    public static func get<T: Recurring>(entity: T?,
                                         completion: ((T?) -> Void)?) {
        RecurringBuilder<T>(type: .fetch, entity: entity)
            .execute(completion: completion)
    }

    public static func search<T>() -> RecurringBuilder<T> {
        return RecurringBuilder<T>(type: .search)
    }
}
