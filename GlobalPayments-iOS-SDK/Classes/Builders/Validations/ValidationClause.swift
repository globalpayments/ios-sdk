import Foundation

typealias ResultCallback = ((NSObject) -> Bool)

class ValidationClause {
    /// All Validations
    public let parent: Validations
    /// Target of this validation clause
    public let target: ValidationTarget
    /// Property to check
    public let propertyName: String
    /// Callback to test a given property
    public var callback: ResultCallback?
    /// Failed validation message
    public var message: String?
    /// Validation clause is a precondition
    public let precondition: Bool

    public init(parent: Validations,
                target: ValidationTarget,
                propertyName: String,
                callback: ResultCallback? = nil,
                message: String? = nil,
                precondition: Bool = false) {

        self.parent = parent
        self.target = target
        self.propertyName = propertyName
        self.callback = callback
        self.message = message
        self.precondition = precondition
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
    @discardableResult public func isInstanceOf<T>(type: T.Type, message: String? = nil) -> ValidationTarget? {
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
        let mirror = Mirror(reflecting: self)
        let child = mirror.allChildren.filter { $0.label == property }.first
        return Optional.isNil(child?.value) ? nil : child?.value
    }

    public func setValue(_ value: Any?, for property: String) {
        guard responds(to: Selector(property)) else { return }
        setValue(value, forKey: property)
    }
}

private extension Mirror {

    var allChildren: [Mirror.Child] {
        var allChildren = [Mirror.Child]()
        var mirror: Mirror! = self
        repeat {
            allChildren.append(contentsOf: mirror.children)
            mirror = mirror.superclassMirror
        } while mirror != nil
        return allChildren
    }
}

private extension Optional {

    static func isNil(_ object: Wrapped) -> Bool {
        switch object as Any {
        case Optional<Any>.none:
            return true
        default:
            return false
        }
    }
}
