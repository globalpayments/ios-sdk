import Foundation

@objcMembers public class BaseBuilder<TResult>: NSObject {

    let validations: Validations

    public override init() {
        self.validations = Validations()
        super.init()
        setupValidations()
    }

    public func execute(configName: String = "default",
                        completion: ((TResult?, Error?) -> Void)?) {
        do {
            try validations.validate(builder: self)
            completion?(nil, nil)
        } catch {
            completion?(nil, error)
        }
    }

    public func setupValidations() { }
}
