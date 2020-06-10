import Foundation

@objcMembers public class RecurringService: NSObject {

    public static func create(entity: RecurringEntity) -> Any? {
        return RecurringBuilder(type: .create, entity: entity).execute()
    }

    public static func delete(entity: RecurringEntity) -> Any? {
        return RecurringBuilder(type: .delete, entity: entity).execute()
    }

    public static func edit(entity: RecurringEntity) -> Any? {
        return RecurringBuilder(type: .edit, entity: entity).execute()
    }

    public static func get(entity: RecurringEntity) -> Any? {
        return RecurringBuilder(type: .fetch, entity: entity).execute()
    }

    public static func search(entity: RecurringEntity) -> RecurringBuilder {
        return RecurringBuilder(type: .search, entity: entity)
    }
}
