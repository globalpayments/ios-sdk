import Foundation

public class FraudRule {
    public var key: String?
    public var mode: FraudFilterMode?
    public var description: String?
    public var result: String?
    
    public init?(doc: JsonDoc?) {
        self.key = doc?.getValue(key: "reference")
        self.result = doc?.getValue(key: "result")
        self.description = doc?.getValue(key: "description")
        self.mode = FraudFilterMode(value: doc?.getValue(key: "mode"))
    }
    
    public init(){}
}
