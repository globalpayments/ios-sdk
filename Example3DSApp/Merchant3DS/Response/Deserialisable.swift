import Foundation

/// Protocol for the deserialization of types
protocol Deserialisable {
    /// Method which takes data from the handler process and returns the Type of the object.
    ///
    /// - Parameter data: Response data from the handler process.
    /// - Returns: The type of the object.
    static func deserialize<T>(from data: Data?) -> T?
}
