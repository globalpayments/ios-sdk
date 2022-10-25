import Foundation

public class FraudRuleCollection {
    
    public var rules:[FraudRule]
    
    public init() {
        rules = []
    }
    
    public func addRule(_ key: String,  mode: FraudFilterMode) {
        if (hasRule(key)) {
            return
        }
        
        let fraudRule = FraudRule()
        fraudRule.key = key
        fraudRule.mode = mode
        rules.append(fraudRule)
    }
    
    private func hasRule(_ key: String)-> Bool {
        var hasRule = false
        rules.forEach { fraudRule in
            if fraudRule.key == key {
                hasRule = true
            }
        }
        return hasRule
    }
    
}
