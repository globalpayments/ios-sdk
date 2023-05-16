import Foundation

public protocol JsonToObject {
    static func mapToObject<T>(_ doc: JsonDoc) -> T?
}
