import Foundation

public class ValidationTarget: NSObject {
    /// All Validations
    public let parent: Validations
    /// Validation type
    public let type: RuleType
    /// Validation modifier
    public var modifier: TransactionModifier?
    /// Property to validate
    public var property: String?
    /// Specified validations to test against the property's value
    public var clause: ValidationClause?
    /// Specified validations to test against the property's value
    public var precondition: ValidationClause?

    public init(parent: Validations,
                type: RuleType,
                modifier: TransactionModifier? = nil,
                property: String? = nil,
                clause: ValidationClause? = nil) {

        self.parent = parent
        self.type = type
        self.modifier = modifier
        self.property = property
        self.clause = clause
    }

    public func with(modifier: TransactionModifier?) -> ValidationTarget {
        self.modifier = modifier
        return self
    }

    public func check(propertyName: String) -> ValidationClause? {
        clause = ValidationClause(
            parent: parent,
            target: self,
            propertyName: propertyName
        )
        return clause
    }

    public func when(propertyName: String) -> ValidationClause? {
        precondition = ValidationClause(
            parent: parent,
            target: self,
            precondition: true,
            propertyName: propertyName
        )
        return precondition
    }
}
