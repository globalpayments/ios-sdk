import Foundation

public class BaseBuilder<TResult>: NSObject {

    let validations: Validations

    public override init() {
        self.validations = Validations()
        super.init()
        setupValidations()
    }

    public func execute(completion: ((TResult?) -> Void)?){
        try! validations.validate(builder: self)
        completion?(nil)
    }

    public func setupValidations() { }

    public func value(for property: String) -> Any? {
        guard responds(to: Selector(property)) else {
            return nil
        }
        return value(forKey: property)
    }
}
