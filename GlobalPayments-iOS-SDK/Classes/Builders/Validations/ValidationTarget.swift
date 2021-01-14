import Foundation

class ValidationTarget {
    /// All Validations
    let parent: Validations
    /// Specified validations to test against the property's value
    var precondition: ValidationClause?
    /// Specified validations to test against the property's value
    var clause: ValidationClause?
    /// Validation type
    let type: RuleType
    /// Validation modifier
    var modifier: TransactionModifier?
    /// Property to validate
    var property: String?

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
            propertyName: propertyName,
            precondition: true
        )
        return precondition
    }
}
