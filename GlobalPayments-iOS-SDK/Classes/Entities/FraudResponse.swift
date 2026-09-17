import Foundation

public class FraudResponse {
    public var assessments: [FraudMode]?
    
    public init?(docs: [JsonDoc]?) {
        self.assessments = docs?.compactMap({ doc in
            let fraudMode = FraudMode()
            fraudMode.result = doc.getValue(key: "result") ?? ""
            fraudMode.mode = doc.getValue(key: "mode")
            fraudMode.message = doc.getValue(key: "message")
            if let rules: [JsonDoc] = doc.getValue(key: "rules") {
                fraudMode.rules = rules.compactMap({ rule in
                    return FraudRule(doc: rule)
                })
            }
            return fraudMode
        })
    }
}
