import Foundation

public typealias ResultCallback = ((NSObject) -> Bool)

public class ValidationClause {
    /// All Validations
    public let parent: Validations
    /// Target of this validation clause
    public let target: ValidationTarget
    /// Validation clause is a precondition
    public let precondition: Bool
    /// Failed validation message
    public var message: String?
    /// Property to check
    public let propertyName: String
    /// Callback to test a given property
    public var callback: ResultCallback?

    public init(parent: Validations,
                target: ValidationTarget,
                precondition: Bool = false,
                message: String? = nil,
                propertyName: String,
                callback: ResultCallback? = nil) {

        self.parent = parent
        self.target = target
        self.precondition = precondition
        self.message = message
        self.propertyName = propertyName
        self.callback = callback
    }

    /// Validates the target property is not null
    /// - Parameters:
    ///   - message: Validation message to override the default
    ///   - subProperty: Parent of current property
    /// - Returns: ValidationTarget
    @discardableResult public func isNotNil(message: String? = nil) -> ValidationTarget? {
        callback = { builder in
            return builder.value(for: self.propertyName) != nil
        }
        self.message = message ?? String(format: "%@ cannot be null for this transaction type.", propertyName)

        return precondition ? target : parent.of(ruleType: target.type)?.with(modifier: target.modifier)
    }

    /// Validates the target property is null
    /// - Parameter message: Validation message to override the default
    /// - Returns: ValidationTarget
    @discardableResult public func isNil(message: String? = nil) -> ValidationTarget? {
        callback = { builder in
            return builder.value(for: self.propertyName) == nil
        }
        self.message = message ?? String(format: "%@ can be null for this transaction type.", propertyName)

        return precondition ? target : parent.of(ruleType: target.type)?.with(modifier: target.modifier)
    }

    /// Validates the target class is instance of
    /// - Parameters:
    ///   - class: AnyClass
    ///   - message: Validation message to override the default
    /// - Returns: ValidationTarget
    @discardableResult public func isInstanceOf<T>(type: T, message: String? = nil) -> ValidationTarget? {
        callback = { builder in
            let value = builder.value(for: self.propertyName)
            return value is T
        }
        self.message = message ?? String(
            format: "%@ must be an instance of %@ class", propertyName, String(describing: T.self)
        )

        return precondition ? target : parent.of(ruleType: target.type)?.with(modifier: target.modifier)
    }

    /// Validates the target class is conforms to specified protocol
    /// - Parameters:
    ///   - protocol: Protocol
    ///   - message: Validation message to override the default
    /// - Returns: ValidationTarget
    @discardableResult public func conformsTo(protocol: Protocol, message: String? = nil) -> ValidationTarget? {
        callback = { builder in
            let value = builder.value(for: self.propertyName) as AnyObject
            return value.conforms(to: `protocol`)
        }
        self.message = message ?? String(
            format: "%@ must conforms to %@ protocol", propertyName, String(describing: `protocol`)
        )

        return precondition ? target : parent.of(ruleType: target.type)?.with(modifier: target.modifier)
    }

    /// Validates the target property is equal to the expected value
    /// - Parameters:
    ///   - expected: expected value
    ///   - message: Validation message to override the default
    /// - Returns: ValidationTarget
    @discardableResult public func isEqualTo(expected: Any, message: String? = nil) -> ValidationTarget? {
        callback = { builder in
            guard let value = builder.value(for: self.propertyName) else {
                return false
            }
            return type(of: value) == type(of: expected)
        }
        self.message = message ?? String(
            format: "%@ was not the expected value %@", propertyName, String(describing: expected)
        )

        return precondition ? target : parent.of(ruleType: target.type)?.with(modifier: target.modifier)
    }

    /// Validates the target property is NOT equal to the expected value
    /// - Parameters:
    ///   - expected: expected value
    ///   - message: Validation message to override the default
    /// - Returns: ValidationTarget
    @discardableResult public func isNotEqualTo(expected: Any, message: String? = nil) -> ValidationTarget? {
        callback = { builder in
            guard let value = builder.value(for: self.propertyName) else {
                return false
            }
            return type(of: value) != type(of: expected)
        }
        self.message = message ?? String(
            format: "%@ cannot be the value %@", propertyName, String(describing: expected)
        )

        return precondition ? target : parent.of(ruleType: target.type)?.with(modifier: target.modifier)
    }
}

extension NSObject {
    public func value(for property: String) -> Any? {
        guard responds(to: Selector(property)) else {
            return nil
        }
        return value(forKey: property)
    }

    public func setValue(_ value: Any?, for property: String) {
        guard responds(to: Selector(property)) else { return }
        setValue(value, forKey: property)
    }
}
