import Foundation

private typealias ValidationRules = [RuleType: [ValidationTarget]]

public class Validations: NSObject {

    private var rules: ValidationRules

    public required override init() {
        self.rules = ValidationRules()
    }

    public func of(ruleType: RuleType) -> ValidationTarget? {
        if let transactionType = ruleType.transactionType {
            return of(transactionType: transactionType)
        }
        if let paymentMethodType = ruleType.paymentMethodType {
            return of(paymentMethodType: paymentMethodType)
        }
        return nil
    }

    public func of(transactionType: TransactionType) -> ValidationTarget {
        let ruleType = RuleType(transactionType: transactionType)
        return addRule(ruleType)
    }

    public func of(paymentMethodType: PaymentMethodType) -> ValidationTarget {
        let ruleType = RuleType(paymentMethodType: paymentMethodType)
        return addRule(ruleType)
    }

    private func addRule(_ rule: RuleType) -> ValidationTarget {
        if !rules.keys.contains(rule) {
            rules[rule] = [ValidationTarget]()
        }

        let target = ValidationTarget(parent: self, type: rule)
        rules[rule]?.append(target)

        return target
    }

    public func validate(builder: BaseBuilder) throws {
        for key in rules.keys {

            var value: Any?
            if key.transactionType != nil {
                value = Validations.getTransactionType(in: builder)
            }
            if key.paymentMethodType != nil {
                value = Validations.getPaymentMethodType(in: builder)
            }
            if value == nil, builder is TransactionBuilder {
                if key.transactionType != nil,
                    let transactionBuilder = builder as? TransactionBuilder {
                    value = Validations.getTransactionType(in: transactionBuilder)
                    if value == nil { continue }
                }
                if key.paymentMethodType != nil,
                    let transactionBuilder = builder as? TransactionBuilder {
                    value = Validations.getPaymentMethodType(in: transactionBuilder)
                    if value == nil { continue }
                }
            }

            guard key.contains(value: value) else { continue }
            guard let validations = rules[key] else { continue }

            for validation in validations {
                if validation.clause == nil { continue }

                // Modifier
                if validation.modifier != nil {
                    let modifier = Validations.getTransactionModifier(in: builder)
                    if validation.modifier != modifier {
                        continue
                    }
                }

                // Check precondition
                if let callback = validation.precondition?.callback {
                    if !callback(builder) {
                        continue
                    }
                }

                if let result = validation.clause?.callback?(builder) {
                    if !result {
                        throw BuilderException.generic(
                            message: validation.clause?.message
                        )
                    }
                }
            }
        }
    }
}

extension Validations {

    private static func getTransactionType(in baseBuilder: BaseBuilder) -> TransactionType? {
        return baseBuilder.value(for: "transactionType") as? TransactionType
    }

    private static func getPaymentMethodType(in baseBuilder: BaseBuilder) -> PaymentMethodType? {
        return baseBuilder.value(for: "paymentMethodType") as? PaymentMethodType
    }

    private static func getTransactionModifier(in baseBuilder: BaseBuilder) -> TransactionModifier? {
        return baseBuilder.value(for: "transactionModifier") as? TransactionModifier
    }
}

public class RuleType: NSObject {
    let transactionType: TransactionType?
    let paymentMethodType: PaymentMethodType?

    init(transactionType: TransactionType? = nil,
         paymentMethodType: PaymentMethodType? = nil) {

        self.transactionType = transactionType
        self.paymentMethodType = paymentMethodType
    }

    func contains(value: Any?) -> Bool {
        if let type = value as? TransactionType {
            return transactionType == type
        }
        if let type = value as? PaymentMethodType {
            return paymentMethodType == type
        }
        return false
    }
}

protocol Test {
    associatedtype ElementType
    func type() -> ElementType
}

extension TransactionType: Test {

    func type() -> TransactionType {
        return self
    }
}

extension PaymentMethodType: Test {
    func type() -> PaymentMethodType {
        return self
    }
}
