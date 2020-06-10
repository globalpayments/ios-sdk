import Foundation

@objcMembers public class BaseBuilder: NSObject {

    let validations: Validations

    public init(validations: Validations = Validations()) {
        self.validations = validations
        super.init()
        setupValidations()
    }

    @discardableResult public func execute() -> Any? {
        try! validations.validate(builder: self)
        return nil
    }

    public func setupValidations() { }

    public func value(for property: String) -> Any? {
        guard responds(to: Selector(property)) else {
            return nil
        }
        return value(forKey: property)
    }
}
