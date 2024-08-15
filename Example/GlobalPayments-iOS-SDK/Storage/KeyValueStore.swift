import Foundation

protocol KeyValueStore: class {
    func get<T>(_ key: ValuesKey<T>) -> T?
    func set<T>(_ key: ValuesKey<T>, to value: T)
    func remove<T>(_ keys: [ValuesKey<T>])
}

extension UserDefaults: KeyValueStore {

    subscript<T>(_ key: ValuesKey<T?>) -> T? {
        get { return object(forKey: key.key) as? T }
        set { set(newValue, forKey: key.key) }
    }

    func get<T>(_ key: ValuesKey<T>) -> T? {
        return object(forKey: key.key) as? T
    }

    func set<T>(_ key: ValuesKey<T>, to value: T) {
        set(value, forKey: key.key)
    }

    func remove<T>(_ key: ValuesKey<T>) {
        removeObject(forKey: key.key)
    }

    func remove<T>(_ keys: [ValuesKey<T>]) {
        keys.forEach { remove($0)}
    }

    func get<T: Codable>(_ key: ValuesKey<T>) -> T? {
        if UserDefaults.isNativelySupportedType(T.self) {
            return object(forKey: key.key) as? T
        }

        guard
            let data = object(forKey: key.key) as? Data
            else {
                return nil
        }
        do {
            return try JSONDecoder().decode(T.self, from: data)
        } catch {
            return nil
        }

    }

    func set<T: Codable>(_ key: ValuesKey<T>, to value: T) throws {
        try set(_encode(value), forKey: key.key)
    }

    fileprivate func _encode<T: Codable>(_ value: T) throws -> Data {
        try JSONEncoder().encode(value)
    }

    static func isNativelySupportedType<T>(_ type: T.Type) -> Bool {
        switch type {
        case is Bool.Type,
             is String.Type,
             is Int.Type,
             is Double.Type,
             is Float.Type,
             is Date.Type,
             is Data.Type:
            return true
        default:
            return false
        }
    }
}
